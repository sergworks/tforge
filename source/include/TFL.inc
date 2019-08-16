{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2019         * }
{ *********************************************************** }

{$IFDEF FPC}
  {$mode delphi}
  {$asmmode intel}
{$ENDIF}

// if limb size is not defined in compiler settings,
//   define 32-bit limb size
{$IFNDEF TFL_LIMB8}
  {$IFNDEF TFL_LIMB16}
    {$IFNDEF TFL_LIMB32}
      {$IFNDEF TFL_LIMB64}
        {$DEFINE TFL_LIMB32}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{.$DEFINE TFL_STDCALL}              // deprecated
{.$DEFINE TFL_CATCH_MEMORY_ERRORS}  // may be needed to build dll

// -----------------------------------------------------

// build targets :
// TFL_CPU386_WIN32   - intel x86 32- or 64-bit CPU on 32-bit Windows
// TFL_CPUX86_WIN32   - intel x86 32- or 64-bit CPU on 32-bit Windows
// TFL_CPUX86_WIN64   - intel x86 64-bit CPU on 64-bit Windows
// TFL_CPUX86_LINUX64 - intel x86 64-bit CPU on 64-bit Linux

{$IFDEF FPC}
  {$IFDEF CPUX86_64}
    {$DEFINE CPUX64}
    {$IFDEF LINUX}
      {$DEFINE LINUX64}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF CPU386}
  {$IFDEF WIN32}
    {$DEFINE TFL_CPUX86_WIN32}
    {$IFDEF TFL_LIMB32}
      {$DEFINE TFL_CPU386_WIN32_LIMB32}
      {$DEFINE TFL_CPUX86_WIN32_LIMB32}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF CPUX64}
  {$IFDEF WIN64}
    {$DEFINE TFL_CPUX64_WIN64}
    {$IFDEF TFL_LIMB32}
      {$DEFINE TFL_CPUX64_WIN64_LIMB32}
    {$ENDIF}
  {$ENDIF}
  {$IFDEF LINUX64}
    {$DEFINE TFL_CPUX64_LINUX64}
    {$IFDEF TFL_LIMB32}
      {$DEFINE TFL_CPUX64_LINUX64_LIMB32}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

