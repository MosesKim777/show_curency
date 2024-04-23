%%%-------------------------------------------------------------------
%%% @author moisej
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Apr 2024 17:42
%%%-------------------------------------------------------------------
-module(request_handler).
-author("moisej").

%% API
-export([init/2, handle/2, terminate/3]).


% init HTTP connection
init(Req0, Opts) ->
  Req = handle(Req0, Opts),
  {ok, Req, Opts}.


handle(Req, _State) ->
  Massage = show_curency:get_curency(),
  cowboy_req:reply(200,
    #{<<"content-type">> => <<"application/xml">>},
    Massage,
    Req).

terminate(_Reason, _Req, _Data) ->
  ok.