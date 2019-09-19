%% @author extle
%% @doc @todo Add description to bubblesort.


-module(bubblesort).

%% ====================================================================
%% API functions
%% ====================================================================
-export([sort/1]).


%% ====================================================================
%% Internal functions
%% ====================================================================


sort([]) -> [];	% empty list
sort([X | []]) -> [X]; % one-elem list
sort([H | T]) -> sort([H | T], []). % make bubble sorting

sort([], Out) -> Out;	% no elem for look-up
sort(Src, Out) -> [MaxEl | T] = maxEl(Src, []), % get the max elem value
				  sort(T, [MaxEl | Out]).	% append max elem to `Out` and find max elem within rest elems

maxEl([Max], T) -> [Max | T]; % ret max elem
maxEl([A, B | C], T) -> if A > B -> % A -> MaxList
							   maxEl([A | C], [B | T]);
						   true -> % else: B -> MaxList
							   maxEl([B | C], [A | T])
						end.


