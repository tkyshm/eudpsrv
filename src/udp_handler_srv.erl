-module(udp_handler_srv).

%% API
-export([start_link/1]).

%% callback
-export([init/1]).


%% =================================================================
%% API
%% =================================================================
start_link(Packet) ->
    proc_lib:start_link(?MODULE, init, [[self(), Packet]]).

%% =================================================================
%% Callback
%% =================================================================
init([Parent, Packet]) ->
    proc_lib:init_ack(Parent, {ok, self()}),
    echo(Packet),
    exit(normal).


%% =================================================================
%% Internal
%% =================================================================
echo({udp, Socket, Ip, Port, Payload}) ->
    Msg = binary_to_list(Payload),
    NewPayload = list_to_binary(string:concat("[ECHO] ",Msg)),
    gen_udp:send(Socket, Ip, Port, NewPayload).

