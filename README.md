# Game of life

File in this reposetory gives CLI implementation of Conway's Game of Life in Prolog on torus shaped plane.

There are two examples (glider and random big test) of the usage.

## Usage

You can start the file from console in two ways:

Use swipl -s life.pl -g main -t halt in command line and it will start glider example or swipl -s life.pl -g big_test -t halt to start big test.

Also, you can write swipl life.pl and then start main or glider or big_test predicate.

For simplicity, I will assume that we are starting code after swipl life.pl.

Note, that there are default values in main, so in fact you can customize it. For example, following line is equivalent to just calling main: glider(Glider), main([frame(Glider), a(2), b(3), c(3), alive('#'), dead(' '), k(-1)]).

glider(Glider), main([frame(Glider), a(2), b(3), c(3), alive('#'), dead(' '), k(-1)]).

So, when you start main you can input following arguments:
	- frame(X): the initiall state. Note that if you want to make rectangular you need to input all cells of this rectangular, even empty rows and columns.
	- a(X), b(X), c(X): theshholds for the rules of next frame. If number of neighbors is less then a or more then b and cell is alive it will become dead. If cell is alive and in range from a to b then it will remaine alive. If cell is dead and number of neighbors that are alive is c then cell becomes dead and otherwise it will be alive.
	- alive(X): the character that will be outputed on the place of cell which is alive.
	- dead(X): the character that will be outputed on the place of cell which is dead.
	- k(X): number of frames it will simulate. If X == -1 then it will output frames infinitely.
Note that X is variable since it is writen with big letter while functions (predicates) are written from small character.
