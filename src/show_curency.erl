%%%-------------------------------------------------------------------
%%% @author moisej
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Apr 2024 17:22
%%%-------------------------------------------------------------------
-module(show_curency).
-author("moisej").

-behaviour(gen_server).

-define(CURRENT_TIME, calendar:datetime_to_gregorian_seconds(calendar:universal_time())).
-define(EXPIRED_TIME, calendar:datetime_to_gregorian_seconds(calendar:universal_time()) + 60).


-record(cache,{
  data,
  expired_time
}).

-export([
  get_curency/0
]).

-export([
  start_link/0
]).

-export([
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).

get_curency() ->
  gen_server:call(?MODULE, show_currency).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
  ets:new(currency_cache, [set,named_table]),
  {ok, []}.

handle_call(show_currency, _From, State) ->
  Reply = show_currency(),
  {reply, Reply, State};

handle_call(_Request, _From, State) ->
  Reply = ok,
  {reply, Reply, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

show_currency() ->
  case ets:lookup(currency_cache, currency) of
    [] ->
      Data = get_currency_from_private_bank(),
      insert_data_to_ets(Data),
      return_xml(Data);
    [{currency, #cache{data = Data0, expired_time = ExpiredTime}}] ->
      case ExpiredTime >= ?CURRENT_TIME of
        true -> return_xml(Data0);
        false ->
          Data = get_currency_from_private_bank(),
          insert_data_to_ets(Data),
          return_xml(Data)
      end
  end.

get_currency_from_private_bank() ->
  {ok, {_Status, _Headers, Body}} = httpc:request(get, {"https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5", []}, [], []),
  Data = jiffy:decode(Body),
  Data.

insert_data_to_ets(Data) ->
  ets:insert(currency_cache, {currency, #cache{data = Data, expired_time = ?EXPIRED_TIME}}).


return_xml(Data) ->
  [{[{<<"ccy">>,Ccy},
    {<<"base_ccy">>,BaseCcy},
    {<<"buy">>,Buy},
    {<<"sale">>,Sale}]},
    {[{<<"ccy">>,Ccy0},
      {<<"base_ccy">>,BaseCcy0},
      {<<"buy">>,Buy0},
      {<<"sale">>,Sale0}]}] = Data,
  Row = lists:flatten(io_lib:format("<row><exchangerate ccy=\"~s\" base_ccy=\"~s\" buy=\"~s\" sale=\"~s\"/></row>", [Ccy, BaseCcy, Buy, Sale])),
  Row0 = lists:flatten(io_lib:format("<row><exchangerate ccy=\"~s\" base_ccy=\"~s\" buy=\"~s\" sale=\"~s\"/></row>", [Ccy0, BaseCcy0, Buy0, Sale0])),
  "<exchangerates>" ++ Row ++ Row0 ++ "</exchangerates>".
