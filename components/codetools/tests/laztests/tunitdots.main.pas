unit tunitdots.main;

{$mode objfpc}{$H+}

interface

uses
  unitdots.dot, unitdots; // unit names (with or without namespaces) win over used interface identifiers
                          // even though the 'unitdots.dot' is left of 'unitdots'

implementation

begin
  unitdots{declaration:tunitdots.main.unitdots}.dot{declaration!:tunitdots.main.unitdots.dot}.test{declaration:unitdots.dot.test}:=3;
  unitdots{declaration:tunitdots.main.unitdots}.dot{declaration!:tunitdots.main.unitdots.dot}.foo{declaration:unitdots.dot.foo}:=4;
  //unitdots.dot.bar:='5'; fail!
  unitdots.my{declaration:unitdots.my}:=false;
end.

