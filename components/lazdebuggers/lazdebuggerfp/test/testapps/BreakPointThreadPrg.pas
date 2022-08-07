program BreakPointThreadPrg;
{$ASMMODE   att}
uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  sysutils, Classes;

type

  { TTestThread }

  TTestThread = class(TThread)
    procedure Execute; override;
  end;


var
  x, BreakDummy: Integer;
  ThrCount: Integer = 0;

{$asmMode intel}

label
testasmlbl1, testasmlbl2;

{ TTestThread }

procedure TTestThread.Execute;
begin
  InterlockedIncrement(ThrCount);
  asm
    nop  // TEST_BREAKPOINT=BrkThreadBegin
    xor eax, eax
    xor ebx, ebx
    add eax, 1023
testasmlbl1:
    sub eax, 1023
    add eax,   1 // TEST_BREAKPOINT=BrkThread1
    add eax,   2 // TEST_BREAKPOINT=BrkThread2
    add eax,   4 // TEST_BREAKPOINT=BrkThread3
    add eax,   8 // TEST_BREAKPOINT=BrkThread4
    add eax,  16 // TEST_BREAKPOINT=BrkThread5
    add eax,  32 // TEST_BREAKPOINT=BrkThread6
    add eax,  64 // TEST_BREAKPOINT=BrkThread7
    add eax, 128 // TEST_BREAKPOINT=BrkThread8
    add eax, 256 // TEST_BREAKPOINT=BrkThread9
    add eax, 512 // TEST_BREAKPOINT=BrkThread10

    add ebx, 1 // TEST_BREAKPOINT=BrkThreadIncLoop
    jmp testasmlbl1 // TEST_BREAKPOINT=BrkThread11

    nop
    nop  // TEST_BREAKPOINT=BrkThreadEnd
  end;
end;

begin
  TTestThread.Create(False);
  TTestThread.Create(False);
  TTestThread.Create(False);
  TTestThread.Create(False);
  TTestThread.Create(False);
  sleep(100);

  TTestThread.Create(False);
  TTestThread.Create(False);
  TTestThread.Create(False);
  TTestThread.Create(False);
  TTestThread.Create(False);

  while ThrCount < 10 do sleep(20);
  sleep(500);
  BreakDummy := 1;

  asm
    nop  // TEST_BREAKPOINT=BrkMainBegin
    xor eax, eax
    xor ebx, ebx
    add eax, 20
testasmlbl2:
    sub eax, 20
    add eax, 1 // TEST_BREAKPOINT=BrkMain1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1 // TEST_BREAKPOINT=BrkMain2
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1 // TEST_BREAKPOINT=BrkMain3
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1
    add eax, 1

    add ebx, 1
    jmp testasmlbl2

    nop
    nop  // TEST_BREAKPOINT=BrkMainEnd
  end;

end.

