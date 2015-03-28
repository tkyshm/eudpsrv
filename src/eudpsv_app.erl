-module(eudpsv_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, [{handlers,LogConfig}]} = application:get_env(eudpsv, lager),
    application:set_env(lager, handlers, LogConfig),
    application:start(lager),
    lager:info("start lager for logger."),
    eudpsv_sup:start_link().

stop(_State) ->
    ok.


-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

simple_test() ->
    ok = application:start(eudpsv),
    ?assertNot(undefined == whereis(eudpsv_sup)).
-endif.
