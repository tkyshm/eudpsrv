-module(udp_srv).
-behaviour(gen_server).
-define(SERVER, ?MODULE).
-include("server_const.hrl").
%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0, start_link/1, stop/0]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% state
%% ------------------------------------------------------------------

-record(state, {
          socket
         }).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link(Port) ->
    %gen_server:start_link({local, ?SERVER}, ?MODULE, [{id, Id}, {socket, Socket}], []).
    gen_server:start_link(?MODULE, [Port], []).

start_link() ->
    {ok, RtpConf} = application:get_env(eudpsv, udp_conf),
    Port = proplists:get_value(port, RtpConf),
    start_link(Port).

stop() ->
    gen_server:cast(?SERVER, stop).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([Port]) ->
    case gen_udp:open(Port, [{active, true}, binary]) of
        {ok, Sock} ->
            {ok, #state{socket=Sock}};
        {error, Reason} ->
            %inet:setops(Socket,[{active, once}]),
            lager:error("Cannnot open 'gen_udp'. :~p",[Reason]),
            {stop, normal, #state{socket = undefined}}
    end.

handle_call(_Request, _From, State) ->
    io:format("No reply...~n"),
    {noreply, State}.

handle_cast(stop, State) ->
    lager:info("---stop server----"), %% Checking packet
    {stop, normal, State}.

handle_info(timeout, #state{socket = undefined} = State) ->
    {noreply, State};
handle_info(timeout, #state{socket = Socket} = State) ->
    To = case gen_udp:recv(Socket, 4) of
             {error, _} -> 10;
             _Data ->
                 10
         end,
    {noreply, State, To};
handle_info(Msg, State) ->
    lager:info("~p",[Msg]), %% Checking packet
    udp_handler_sup:handle(Msg),
    {noreply, State}.

terminate(_Reason, State) ->
    gen_udp:close(State#state.socket),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

