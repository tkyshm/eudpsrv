-module(eudpsv_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-include("server_const.hrl").

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    %%%% set udp config parameters
    %%{ok, RtpConf} = application:get_env(eudpsv, udp_conf),
    %%Port = proplists:get_value(port, RtpConf),
    %%lager:info("UDP server port number - Port: ~p.",[Port]),
    %%%% open UDP socket 
    %%{ok, Socket} = gen_udp:open(Port, [binary, {active, true}]),
    %%inet:setopts(Socket,[{active, once}]),
    %%lager:info("open udp socket - PID: ~p.",[Socket]),
    %%%%io:format("~p~n",[Socket]),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    RtpServer = ?CHILD(udp_srv, worker),
    RtpHandlerSup = ?CHILD(udp_handler_sup, supervisor),
    Children = [RtpServer, RtpHandlerSup],
    RegStrategy = {one_for_one, 3600, 4},
    {ok, {RegStrategy, Children}}.


