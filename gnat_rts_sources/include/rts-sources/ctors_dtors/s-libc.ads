------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                           S Y S T E M . L I B C                          --
--                                                                          --
--                                 S p e c                                  --
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

--  This package mimics the functionality from the C library to execute
--  dynamic initialization and termination for non-local variables and
--  routines to execute at program termination.

pragma Restrictions (No_Elaboration_Code);

with Interfaces.C;

package System.Libc is
   type Proc_Access is access procedure
     with Convention => C, Suppress_Initialization;
   --  Pointers registered for initialization and termination

   --  These subprograms implement the dynamic initialization/termination
   --  functionality for non-local variables that is used by the global
   --  constructor/destructor mechanism.
   --  They are called by the startup routine, and are not intended to
   --  be called directly by user code.

   procedure Libc_Init_Array
     with Export, Convention => C, External_Name => "__libc_init_array";

   procedure Libc_Fini_Array
     with Export, Convention => C, External_Name => "__libc_fini_array";

   --  The following subprograms are used to register procedures to be called
   --  at program termination.

   function Atexit (Proc : Proc_Access) return Interfaces.C.int
     with Export, Convention => C, External_Name => "atexit";

   procedure C_Exit (Status : Interfaces.C.int)
     with Export, Convention => C, External_Name => "exit";

end System.Libc;
