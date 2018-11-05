Nonterminals
expressions
expression
lhd
rhd
op
lop
wildcard_value
list_body
list
.

Terminals
space
string
atom
eq neq lte gte lt gt in and or
wc
'(' ')' '[' ']'
.

Rootsymbol expressions.

expressions -> space expressions : '$2'.
expressions -> expression lop expressions : {'$2', '$1', '$3'}.
expressions -> expression : '$1'.
expressions -> rhd : {value, '$1'}.

expression -> '(' expressions ')' : {group, '$2'}.
expression -> lhd op rhd : {exp, {'$2', '$1', '$3'}}.
expression -> lhd op space rhd : {exp, {'$2', '$1', '$4'}}.

lhd -> atom : '$1'.
lhd -> string : '$1'.

rhd -> wildcard_value : {wildcard, '$1'}.
rhd -> atom : '$1'.
rhd -> string : '$1'.
rhd -> list : '$1'.

wildcard_value -> wc wildcard_value : ["*", '$2'].
wildcard_value -> string wc wildcard_value : ['$1', "*", '$3'].
wildcard_value -> atom wc wildcard_value : ['$1', "*", '$3'].
wildcard_value -> wc : ["*"].

list -> '[' list_body ']' : '$2'.

list_body -> space list_body : '$2'.
list_body -> rhd list_body : ['$1'] ++ '$2'.
list_body -> rhd : ['$1'].

op -> space op : '$2'.
op -> eq : uq('$1').
op -> neq : uq('$1').
op -> lte : uq('$1').
op -> gte : uq('$1').
op -> lt : uq('$1').
op -> gt : uq('$1').
op -> in : uq('$1').

lop -> space lop : '$2'.
lop -> and : 'AND'.
lop -> or : 'OR'.

Erlang code.

uq({Value, _}) ->
	Value.
