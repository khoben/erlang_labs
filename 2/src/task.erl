%% @author extle
%% @doc @todo Add description to task.


-module(task).
-compile(export_all).
%% ====================================================================
%% API functions
%% ====================================================================
-export([client/2]).

client(0, _) ->
	io:format("Client: finishing..~n"),
	pingLoop(pang, 'pidHr'),
	resolvePid(pidHr) ! done,
	pingLoop(pang, 'pidWorker'),
	resolvePid(pidWorker) ! done,
	pingLoop(pang, 'pidChairman'),
	resolvePid(pidChairman) ! done,
	io:format("Client: done~n");
	
client(IndexClient, 0) -> % Init new client
	io:format("Client #~w~n", [IndexClient]),
	pingLoop(pang, 'pidChairman'),
	io:format("Client #~w. New task~n", [IndexClient]),
	resolvePid(pidChairman) ! newTask,
	client(IndexClient, 1);

client(IndexClient, 1) -> % Start proccess client
	receive
		taskInProgress -> 
			io:format("Client #~w. Task in progress~n", [IndexClient]),
			client(IndexClient, 1);
		taskFail ->
			io:format("Client #~w. Task failed~n", [IndexClient]),
			client(IndexClient - 1, 0);
		done ->
			io:format("Client #~w. Task finished~n", [IndexClient]),
			client(IndexClient - 1, 0)
end.

chairman() ->
	receive
		newTask -> 
			pingLoop(pang, 'pidHr'),
			io:format("Chairman: search for worker~n"),
			resolvePid(pidHr) ! requestForWorker,
			chairman();
		
		workerFound ->
			io:format("Chairman: worker has been found~n"),
			pingLoop(pang, 'pidClient'),
			resolvePid(pidClient) ! taskInProgress,
			pingLoop(pang, 'pidTask'),
			resolvePid(pidTask) ! doingEdits,
			chairman();
		
		taskDone ->
			io:format("Chairman: task done~n"),
			pingLoop(pang, 'pidClient'),
			resolvePid(pidClient) ! done,
			chairman();
			
		done -> 
			io:format("Chairman: done~n")
end.

hr() ->
	receive
		requestForWorker -> 
			pingLoop(pang, 'pidWorker'),
			io:format("Hr: applying worker~n"),
			resolvePid(pidWorker) ! newTask,
			pingLoop(pang, 'pidChairman'),
			resolvePid(pidChairman) ! workerFound,
			hr();
		
		done -> 
			io:format("Hr: done~n")
end.

worker() ->
	receive
		newTask ->
			pingLoop(pang, 'pidTask'),
			io:format("Worker: task in progress..~n"),
			resolvePid(pidTask) ! doingTask,
			worker();
		requestForEditTask ->
			io:format("Worker: editing task...~n"),
			pingLoop(pang, 'pidTask'),
			resolvePid(pidTask) ! done,
			worker();
		done -> 
			io:format("Worker: done~n")
end.

task() -> 
	receive
		doingTask ->
			io:format("Task: in progress..~n"),
			task();
		doingEdits ->
			pingLoop(pang, 'pidWorker'),
			io:format("Task: need edits..~n"),
			resolvePid(pidWorker) ! requestForEditTask,
			task();
		done -> 
			pingLoop(pang, 'pidChairman'),
			resolvePid(pidChairman) ! taskDone,
			io:format("Task: done~n"),
			task()
end.


runTaskNode() ->
	global:register_name(pidTask, spawn(?MODULE, task, [])).

runChairmanNode() ->
	global:register_name(pidChairman, spawn(?MODULE, chairman, [])).

runClientNode(N) ->
	global:register_name(pidClient, spawn(?MODULE, client, [N, 0])).

runHrNode() ->
	global:register_name(pidHr, spawn(?MODULE, hr, [])).

runWorkerNode() ->
	global:register_name(pidWorker, spawn(?MODULE, worker, [])).

%% ====================================================================
%% Internal functions
%% ====================================================================

% Get pid for %NodeName%
resolvePid(Atom) ->
	global:whereis_name(Atom).

% Build node`s full name
buildNodeAddress(Atom) ->
	list_to_atom(string:concat(erlang:atom_to_list(Atom), "@ASUS-NOTEBOOK")).

pingLoop(pong, NodeName) -> % sets up connection to %NodeName%
	io:format("node ~s registered ~n", [NodeName]),
	checkNodeByName(resolvePid(NodeName), NodeName),
	pingOK;
pingLoop(pang, NodeName) -> % on fail connection, trying to connect...
	timer:sleep(1000),
	pingLoop(net_adm:ping(buildNodeAddress(NodeName)), NodeName).


checkNodeByName(undefined, NodeName) -> % there is no pid with %NodeName%
	pingLoop(pang, NodeName);
checkNodeByName(_, _) -> % %NodeName% exists
	checkOK.

