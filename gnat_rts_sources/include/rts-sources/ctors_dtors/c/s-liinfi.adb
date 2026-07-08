------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                 S Y S T E M . L I B C . I N I T _ F I N I                --
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

--  The initialization and finalization procedures are imported from C to
--  execute the constructors and destructors.

separate (System.Libc)

package body Init_Fini is

   ----------
   -- Init --
   ----------

   procedure Init is
      procedure C_Init
        with Import, Convention => C, External_Name => "_init";
   begin
      C_Init;
   end Init;

   ----------
   -- Fini --
   ----------

   procedure Fini is
      procedure C_Fini
        with Import, Convention => C, External_Name => "_fini";
   begin
      C_Fini;
   end Fini;

end Init_Fini;
