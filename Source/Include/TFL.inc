{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
{ *********************************************************** }

{$IFDEF FPC}
  {$mode delphi}
  {$asmmode intel}
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

{$IFNDEF TFL_LIMB8}
  {$IFNDEF TFL_LIMB16}
    {$IFNDEF TFL_LIMB32}
      {$IFNDEF TFL_LIMB64}
        {$DEFINE TFL_LIMB32}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFNDEF TFL_STDCALL}
  {$IFDEF TFL_DLL}
    {$DEFINE TFL_STDCALL}
  {$ENDIF}
{$ENDIF}

{$IFNDEF TFL_INTFCALL}
  {$IFDEF TFL_DLL}
    {$DEFINE TFL_INTFCALL}
  {$ENDIF}
{$ENDIF}

{$DEFINE TFL_HACK}

// Enable logging
{.$DEFINE TFL_LOG}

// -----------------------------------------------------

// build target:
// TFL_CPU386_WIN32 - intel 386 compatible CPU (32- or 64-bit) on 32-bit Windows
// TFL_CPUX64_WIN64 - intel 64-bit x86 CPU on 64-bit Windows

{$IFDEF FPC}
  {$IFDEF CPUX86_64}
    {$DEFINE CPUX64}
  {$ENDIF}
{$ENDIF}

{$IFDEF CPU386}
  {$IFDEF WIN32}
    {$DEFINE TFL_CPUX86_WIN32}		// deprecated - to be removed later
    {$DEFINE TFL_CPU386_WIN32}
    {$IFDEF TFL_LIMB32}
      {$DEFINE TFL_LIMB32_CPU386_WIN32}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF CPUX64}
  {$IFDEF WIN64}
    {$DEFINE TFL_CPUX64_WIN64}
    {$IFDEF TFL_LIMB32}
      {$DEFINE TFL_LIMB32_CPUX64_WIN64}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
