{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ *********************************************************** }

{$IFDEF FPC}
  {$mode delphi}
  {$DEFINE TFL_POINTERMATH}
{$ENDIF}

{$IFNDEF FPC}
  {$IFDEF CONDITIONALEXPRESSIONS}
     {$IF CompilerVersion >= 20.0}
       {$DEFINE TFL_D2009_PLUS}
       {$DEFINE TFL_POINTERMATH}
       {$DEFINE TFL_EXITPARAM}
       {$DEFINE TFL_ANONYMOUS}
     {$IFEND}
     {$IF CompilerVersion >= 21.0}
       {$DEFINE TFL_D2010_PLUS}
       {$DEFINE TFL_DELAYLOAD}
     {$IFEND}
     {$IF CompilerVersion >= 22.0}
       {$DEFINE TFL_DXE_PLUS}
     {$IFEND}
     {$IF CompilerVersion >= 23.0}
       {$DEFINE TFL_DXE2_PLUS}
     {$IFEND}
  {$ENDIF}
{$ENDIF}

// Enable to build dll
{.$DEFINE TFL_DLL}

// Enable logging
{$DEFINE TFL_LOG}

// Enable intel 32-bit CPU assembler optimization
{.$DEFINE TFL_ASM86}

{$IFNDEF TFL_LIMB8}
  {$IFNDEF TFL_LIMB16}
    {$IFNDEF TFL_LIMB32}
      {$IFNDEF TFL_LIMB64}
        {$DEFINE TFL_LIMB32}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

// -----------------------------------------------------

{$IFDEF TFL_LIMB32}
  {$IFDEF TFL_ASM86}
    {$DEFINE TFL_LIMB32_ASM86}
  {$ENDIF}
{$ENDIF}
