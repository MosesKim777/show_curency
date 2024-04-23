%%%-------------------------------------------------------------------
%%% @author moisej
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Apr 2024 17:22
%%%-------------------------------------------------------------------
-module(show_curency_app).
-author("moisej").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {'_', [{"/show_curency", request_handler, []}]}
  ]),
  {ok, _} = cowboy:start_clear(my_http_listener,
    [{port, 8080}],
    #{env => #{dispatch => Dispatch}}),
  show_curency_sup:start_link().

stop(_State) ->
  ok.

