------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                           S Y S T E M . L I B C                          --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                        Copyright (C) 2025, AdaCore                       --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

with System.Storage_Elements; use System.Storage_Elements;

package body System.Libc is

   --  These are defined by the linker script

   Preinit_Array_Start : Proc_Access
     with Import, External_Name => "__preinit_array_start";

   Preinit_Array_End : Proc_Access
     with Import, External_Name => "__preinit_array_end";

   Init_Array_Start : Proc_Access
     with Import, External_Name => "__init_array_start";

   Init_Array_End : Proc_Access
     with Import, External_Name => "__init_array_end";

   Fini_Array_Start : Proc_Access
     with Import, External_Name => "__fini_array_start";

   Fini_Array_End : Proc_Access
     with Import, External_Name => "__fini_array_end";

   --  Some targets execute constructors and destructors within the _init and
   --  _fini procedures.

   package Init_Fini is
      procedure Init;
      procedure Fini;
   end Init_Fini;

   --  To choose between a null implementation and one importing the C
   --  implementation.

   package body Init_Fini is separate;

   --  Data to hold the termination procedures and their count.
   --  It must be at least 32 to guarantee ANSI conformance.

   Max_Handlers : constant := 32;
   Handlers     : array (1 .. Max_Handlers) of Proc_Access;
   Count        : Natural := 0;

   ---------------------
   -- Libc_Init_Array --
   ---------------------

   procedure Libc_Init_Array is
      Preinit_Count : constant Integer :=
        Integer
          (To_Integer (Preinit_Array_End'Address) -
           To_Integer (Preinit_Array_Start'Address)) /
        (Proc_Access'Size / 8);

      Init_Count : constant Integer :=
        Integer
          (To_Integer (Init_Array_End'Address) -
           To_Integer (Init_Array_Start'Address)) /
        (Proc_Access'Size / 8);

      --  Create arrays to hold the pre-initialization and initialization
      --  procedures. The size of the arrays is determined by the linker
      --  script, which defines the start and end addresses of the arrays.

      Preinit_Array : array (1 .. Preinit_Count) of Proc_Access
        with Import => True, Address => Preinit_Array_Start'Address;

      Init_Array : array (1 .. Init_Count) of Proc_Access
        with Import => True, Address => Init_Array_Start'Address;

   begin
      --  Call each pre-initialization procedure in the array

      for Proc of Preinit_Array loop
         pragma Assert (Proc /= null);
         Proc.all;
      end loop;

      --  Call the _init procedure if needed. Some targets store the
      --  constructors in the .ctors section, and it is the _init procedure
      --  that traverses that list.

      Init_Fini.Init;

      --  Call each initialization procedure in the array

      for Proc of Init_Array loop
         pragma Assert (Proc /= null);
         Proc.all;
      end loop;
   end Libc_Init_Array;

   ---------------------
   -- Libc_Init_Array --
   ---------------------

   procedure Libc_Fini_Array is
      Fini_Count : constant Integer :=
        Integer
          (To_Integer (Fini_Array_End'Address) -
           To_Integer (Fini_Array_Start'Address)) /
        (Proc_Access'Size / 8);

      --  Create array to hold termination procedures. The size of the array
      --  is determined by the linker script, which defines the start and end
      --  addresses of the array.

      Fini_Array : array (1 .. Fini_Count) of Proc_Access
        with Import => True, Address => Fini_Array_Start'Address;

   begin
      --  Call each termination procedure in the array

      for Proc of reverse Fini_Array loop
         pragma Assert (Proc /= null);
         Proc.all;
      end loop;

      --  Call the _fini procedure if needed. Some targets store the
      --  destructors in the .dtors section, and it is the _fini procedure
      --  that traverses that list.

      Init_Fini.Fini;
   end Libc_Fini_Array;

   ------------
   -- Atexit --
   ------------

   function Atexit (Proc : Proc_Access) return Interfaces.C.int is
      use type Interfaces.C.int;
   begin
      --  Register the procedure to be called at program termination
      if Count < Max_Handlers then
         Count := Count + 1;
         Handlers (Count) := Proc;
         return 0;

      --  If the maximum number of handlers is reached, return an error code
      else
         return -1;
      end if;
   end Atexit;

   ------------
   -- C_Exit --
   ------------

   procedure C_Exit (Status : Interfaces.C.int) is
      procedure Os_Exit (Status : Interfaces.C.int)
        with No_Return, Import, External_Name => "_exit";
   begin
      --  Call the termination procedures in reverse order

      for I in reverse 1 .. Count loop
         pragma Assert (Handlers (I) /= null);
         Handlers (I).all;
      end loop;

      --  Call the OS exit function to terminate the program

      Os_Exit (Status);
   end C_Exit;

end System.Libc;
