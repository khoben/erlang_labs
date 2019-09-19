%% @author extle
%% @doc @todo Add description to tests.


-module(bubblesort_tests).

-include_lib("eunit/include/eunit.hrl").

%% ====================================================================
%% API functions
%% ====================================================================



%% ====================================================================
%% Internal functions
%% ====================================================================

%% all_sort_test() ->
%% 	[empty_list_test(),
%% one_elem_list_test(),
%% 	 all_equal_value_test(),
%% 	 basic_sort_test()].

empty_list_test() ->
	?assertEqual(bubblesort:sort([]), []).

one_elem_list_test() ->
	?assertEqual(bubblesort:sort([1]), [1]).

all_equal_value_test() ->
	?assertEqual(bubblesort:sort([1, 1, 1]), [1, 1, 1]).

basic_sort_test() ->
	?assertEqual(bubblesort:sort([4, 3, 2, 1]), [1, 2, 3, 4]).

fail_sort_test() ->
	?assertEqual(bubblesort:sort([4, 3, 2, 1]), [3, 2, 3, 4]).
