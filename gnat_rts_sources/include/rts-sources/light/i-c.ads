------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                         I N T E R F A C E S . C                          --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
-- This specification is derived from the Ada Reference Manual for use with --
-- GNAT.  In accordance with the copyright of that document, you can freely --
-- copy and modify this specification,  provided that if you redistribute a --
-- modified version,  any changes that you have made are clearly indicated. --
--                                                                          --
------------------------------------------------------------------------------

--  This package implements Interfaces.C according to LRM B.3. except
--  Wide_Character and Wide_Wide_Character support.

--  Preconditions in this unit are meant for analysis only, not for run-time
--  checking, so that the expected exceptions are raised. This is enforced by
--  setting the corresponding assertion policy to Ignore. Postconditions and
--  contract cases should not be executed at runtime as well, in order not to
--  slow down the execution of these functions.

pragma Assertion_Policy (Pre            => Ignore,
                         Post           => Ignore,
                         Contract_Cases => Ignore,
                         Ghost          => Ignore);

--  Pre/postconditions use a fully qualified name for the standard "+" operator
--  in order to work around an internal limitation of the compiler.

with System;
with System.Parameters;

package Interfaces.C with
  SPARK_Mode,
  Pure,
  Always_Terminates
is

   --  Each of the types declared in Interfaces.C is C-compatible.

   --  The types int, short, long, unsigned, ptrdiff_t, size_t, double,
   --  char, wchar_t, char16_t, and char32_t correspond respectively to the
   --  C types having the same names. The types signed_char, unsigned_short,
   --  unsigned_long, unsigned_char, C_bool, C_float, and long_double
   --  correspond respectively to the C types signed char, unsigned
   --  short, unsigned long, unsigned char, bool, float, and long double.

   --  Declaration's based on C's <limits.h>

   CHAR_BIT  : constant := 8;
   SCHAR_MIN : constant := -128;
   SCHAR_MAX : constant := 127;
   UCHAR_MAX : constant := 255;

   --  Signed and Unsigned Integers. Note that in GNAT, we have ensured that
   --  the standard predefined Ada types correspond to the standard C types

   --  Note: the Integer qualifications used in the declaration of type long
   --  avoid ambiguities when compiling in the presence of s-auxdec.ads and
   --  a non-private system.address type.

   type int   is new Integer;
   type short is new Short_Integer;
   type long  is range -(2 ** (System.Parameters.long_bits - Integer'(1)))
     .. +(2 ** (System.Parameters.long_bits - Integer'(1))) - 1;
   type long_long is new Long_Long_Integer;

   type signed_char is range SCHAR_MIN .. SCHAR_MAX;
   for signed_char'Size use CHAR_BIT;

   type unsigned           is mod 2 ** int'Size;
   type unsigned_short     is mod 2 ** short'Size;
   type unsigned_long      is mod 2 ** long'Size;
   type unsigned_long_long is mod 2 ** long_long'Size;

   type unsigned_char is mod (UCHAR_MAX + 1);
   for unsigned_char'Size use CHAR_BIT;

   --  Note: Ada RM states that the type of the subtype plain_char is either
   --  signed_char or unsigned_char, depending on the C implementation. GNAT
   --  instead choses unsigned_char always.

   subtype plain_char is unsigned_char;

   --  Note: the Integer qualifications used in the declaration of ptrdiff_t
   --  avoid ambiguities when compiling in the presence of s-auxdec.ads and
   --  a non-private system.address type.

   type ptrdiff_t is
     range -System.Memory_Size / 2 .. System.Memory_Size / 2 - 1;

   type size_t is mod System.Memory_Size;

   --  Boolean type

   type C_bool is new Boolean;
   pragma Convention (C, C_bool);

   --  Floating-Point

   type C_float     is new Float;
   type double      is new Standard.Long_Float;
   type long_double is new Standard.Long_Long_Float;

   ----------------------------
   -- Characters and Strings --
   ----------------------------

   type char is new Character;

   nul : constant char := char'First;

   --  The functions To_C and To_Ada map between the Ada type Character and the
   --  C type char.

   function To_C (Item : Character) return char
   with
     Post => To_C'Result = char'Val (Character'Pos (Item));

   function To_Ada (Item : char) return Character
   with
     Post => To_Ada'Result = Character'Val (char'Pos (Item));

   type char_array is array (size_t range <>) of aliased char;
   for char_array'Component_Size use CHAR_BIT;

   function Is_Nul_Terminated (Item : char_array) return Boolean
   with
     Post => Is_Nul_Terminated'Result = (for some C of Item => C = nul);
   --  The result of Is_Nul_Terminated is True if Item contains nul, and is
   --  False otherwise.

   function C_Length_Ghost (Item : char_array) return size_t
   with
     Ghost,
     Import,
     Pre  => Is_Nul_Terminated (Item),
     Post => C_Length_Ghost'Result <= Item'Last - Item'First
       and then Item (Item'First + C_Length_Ghost'Result) = nul
       and then (for all J in Item'First .. Item'First + C_Length_Ghost'Result
                   when J /= Item'First + C_Length_Ghost'Result =>
                     Item (J) /= nul);
   --  Ghost function to compute the length of a char_array up to the first nul
   --  character.

   function To_C
     (Item       : String;
      Append_Nul : Boolean := True) return char_array
   with
     Pre  => not (Append_Nul = False and then Item'Length = 0),
     Post => To_C'Result'First = 0
       and then To_C'Result'Length =
         (if Append_Nul then Standard."+" (Item'Length, 1) else Item'Length)
       and then (for all J in Item'Range =>
                   To_C'Result (size_t (J - Item'First)) = To_C (Item (J)))
       and then (if Append_Nul then To_C'Result (To_C'Result'Last) = nul);
   --  The result of To_C is a char_array value of length Item'Length (if
   --  Append_Nul is False) or Item'Length+1 (if Append_Nul is True). The lower
   --  bound is 0. For each component Item(I), the corresponding component
   --  in the result is To_C applied to Item(I). The value nul is appended if
   --  Append_Nul is True. If Append_Nul is False and Item'Length is 0, then
   --  To_C propagates Constraint_Error.

   function To_Ada
     (Item     : char_array;
      Trim_Nul : Boolean := True) return String
   with
     Pre  => (if Trim_Nul then
                Is_Nul_Terminated (Item)
                  and then C_Length_Ghost (Item) <= size_t (Natural'Last)
              else
                Item'Last - Item'First < size_t (Natural'Last)),
     Post => To_Ada'Result'First = 1
       and then To_Ada'Result'Length =
         (if Trim_Nul then C_Length_Ghost (Item) else Item'Length)
       and then (for all J in To_Ada'Result'Range =>
                   To_Ada'Result (J) =
                     To_Ada (Item (size_t (J) - 1 + Item'First)));
   --  The result of To_Ada is a String whose length is Item'Length (if
   --  Trim_Nul is False) or the length of the slice of Item preceding the
   --  first nul (if Trim_Nul is True). The lower bound of the result is 1.
   --  If Trim_Nul is False, then for each component Item(I) the corresponding
   --  component in the result is To_Ada applied to Item(I). If Trim_Nul
   --  is True, then for each component Item(I) before the first nul the
   --  corresponding component in the result is To_Ada applied to Item(I). The
   --  function propagates Terminator_Error if Trim_Nul is True and Item does
   --  not contain nul.

   procedure To_C
     (Item       : String;
      Target     : out char_array;
      Count      : out size_t;
      Append_Nul : Boolean := True)
   with
     Relaxed_Initialization => Target,
     Pre  => Target'Length >=
       (if Append_Nul then Standard."+" (Item'Length, 1) else Item'Length),
     Post => Count = (if Append_Nul then Item'Length + 1 else Item'Length)
       and then
         (if Count /= 0 then
           Target (Target'First .. Target'First + (Count - 1))'Initialized)
       and then
         (for all J in Item'Range =>
           Target (Target'First + size_t (J - Item'First)) = To_C (Item (J)))
       and then
         (if Append_Nul then Target (Target'First + (Count - 1)) = nul);
   --  For procedure To_C, each element of Item is converted (via the To_C
   --  function) to a char, which is assigned to the corresponding element of
   --  Target. If Append_Nul is True, nul is then assigned to the next element
   --  of Target. In either case, Count is set to the number of Target elements
   --  assigned. If Target is not long enough, Constraint_Error is propagated.

   procedure To_Ada
     (Item     : char_array;
      Target   : out String;
      Count    : out Natural;
      Trim_Nul : Boolean := True)
   with
     Relaxed_Initialization => Target,
     Pre  => (if Trim_Nul then
                Is_Nul_Terminated (Item)
                  and then C_Length_Ghost (Item) <= size_t (Target'Length)
              else
                Item'Last - Item'First < size_t (Target'Length)),
     Post => Count =
         (if Trim_Nul then Natural (C_Length_Ghost (Item)) else Item'Length)
       and then
         (if Count /= 0 then
           Target (Target'First .. Target'First + (Count - 1))'Initialized)
       and then
         (for all J in Target'First .. Target'First + (Count - 1) =>
           Target (J) =
             To_Ada (Item (size_t (J - Target'First) + Item'First)));
   --  For procedure To_Ada, each element of Item (if Trim_Nul is False) or
   --  each element of Item preceding the first nul (if Trim_Nul is True) is
   --  converted (via the To_Ada function) to a Character, which is assigned
   --  to the corresponding element of Target. Count is set to the number of
   --  Target elements assigned. If Target is not long enough, Constraint_Error
   --  is propagated. If Trim_Nul is True and Item does not contain nul, then
   --  Terminator_Error is propagated.

   Terminator_Error : exception;

end Interfaces.C;
