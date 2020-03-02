# Hello-World-Pascal-Compiler
A repository of a project which exploits Flex lexical analyzer along with Bison parser to produce a simple compiler of Pascal-like procedural language. The compiler generates intermediate asm code, and comes along with a bunch of tests, including bubblesort procedure for integers as well as floating point numbers
# Motivation
I did it as a part of a course during my master studies, thus the repository is provided with exemplary compiler provided by the lecturer to test for correctness
# Usage
You can compile your compiler by just typing make, and run the generated compiler program like:
```
./komp tests/t0.pas 
```
As an output you should see a dump of the symbol table after parsing each procedure, as well as after parsing the whole program.
Such usage is useful when you want to debug your symbol table, but for me it was generally enough to just see the differences in the intermediate code generated by my compiler and exemplary compiler.
For that, in tests/ subdirectory you have 3 helpful scripts:
## 1. test_script.sh
Compiles your program and runs it on all files in tests/ directory which end with .pas and stores results in out_mine/ subdirectory
It also runs the exemplary GWJ compiler on all .pas files in this directory and stores the intermediate code of each file in out_gwj/ subdirectory
### Input
None
### Output
Scrpit prints the name of all processed .pas files 
### Usage
while in tests/ directory type
```
./test_script.sh
```
## 2. diff_between_two_files
This script must be run after test_script, since it uses the files generated in out_mine/ and out_gwj/ subdirectories.
### Input 
It expects one argument, which is the name of the file without file extension.
### Output
It outputs to the console the difference in the generated intermediate code between gwj compiler and your compiler, along with the line number
### Usage
while in tests/ directory type
```
./test_script.sh
./diff_between_two_files.sh t8
```
The exemplary output in the case above would look like
```
     1          jump.i  #example                ;jump.i  #example     |         jump.i  #lab0                   ;jump.i  lab0
     5          add.r   *BP+16,*BP+12,BP-12     ;add.r   *a,*b,$t0    |         add.r   *BP+16,*BP+12,BP-12     ;add.r   a,b,$t0
     8          mov.r   BP-28,*BP+8             ;mov.r   $t2,*f       |         mov.r   BP-28,*BP+8             ;mov.r   $t2,f
    11  example:                                                      | lab0:
```

## 3. remove_test_outputs.sh
Removes all .asm files and cleans the out_mine and out_gwj files
it expects no input, outputs nothing, and the side effect it that you are not flooded with .asm files eveywhere

# That's all folks
Should you have any questions, feel free to contact me