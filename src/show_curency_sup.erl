%%%-------------------------------------------------------------------
%%% @author moisej
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Apr 2024 17:21
%%%-------------------------------------------------------------------
-module(show_curency_sup).
-author("moisej").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
  {ok, {{one_for_one, 5, 10}, [
    {show_curency, {show_curency, start_link, []}, permanent, 5000, worker, [show_curency]}
  ]}}.
