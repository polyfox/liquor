Nonterminals
expressions
expression
lhd
rhd
op
wildcard_value
.

Terminals
list
space
string
atom
eq neq lte gte lt gt in and or
wc
'(' ')' '[' ']'
.

Rootsymbol expressions.

expressions -> expression : '$1'.
expressions -> expression space and space expressions : {'$1', 'AND', '$5'}.
expressions -> expression space and expressions : {'$1', 'AND', '$4'}.
expressions -> expression and space expressions : {'$1', 'AND', '$4'}.
expressions -> expression and expressions : {'$1', 'AND', '$3'}.
expressions -> expression space or space expressions : {'$1', 'OR', '$5'}.
expressions -> expression space or expressions : {'$1', 'OR', '$4'}.
expressions -> expression or space expressions : {'$1', 'OR', '$4'}.
expressions -> expression or expressions : {'$1', 'OR', '$3'}.

expression -> '(' space expressions space ')' : {group, '$3'}.
expression -> '(' space expressions ')' : {group, '$3'}.
expression -> '(' expressions space ')' : {group, '$2'}.
expression -> '(' expressions ')' : {group, '$2'}.
expression -> lhd space op space rhd : {exp, {'$3', '$1', '$5'}}.
expression -> lhd op space rhd : {exp, {'$2', '$1', '$4'}}.
expression -> lhd space op rhd : {exp, {'$3', '$1', '$4'}}.
expression -> lhd op rhd : {exp, {'$2', '$1', '$3'}}.

lhd -> atom : '$1'.
lhd -> string : '$1'.

rhd -> wildcard_value : {wildcard, '$1'}.
rhd -> atom : '$1'.
rhd -> string : '$1'.

wildcard_value -> wc wildcard_value : ["*", '$2'].
wildcard_value -> string wc wildcard_value : ['$1', "*", '$3'].
wildcard_value -> atom wc wildcard_value : ['$1', "*", '$3'].

op -> eq : uq('$1').
op -> neq : uq('$1').
op -> lte : uq('$1').
op -> gte : uq('$1').
op -> lt : uq('$1').
op -> gt : uq('$1').
op -> in : uq('$1').

Erlang code.

uq({Value, _}) ->
	Value.
