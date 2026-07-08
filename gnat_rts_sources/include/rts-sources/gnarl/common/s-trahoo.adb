------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                   S Y S T E M . T R A C I N G _ H O O K S                --
--                                                                          --
--                                  B o d y                                 --
--                                                                          --
--                        Copyright (C) 2025, AdaCore                       --
--                                                                          --
-- GNARL is free software; you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion. GNARL is distributed in the hope that it will be useful, but WITH- --
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
-- GNARL was developed by the GNARL team at Florida State University.       --
-- Extensive contributions were provided by Ada Core Technologies, Inc.     --
--                                                                          --
-- The port of GNARL to bare board targets was initially developed by the   --
-- Real-Time Systems Group at the Technical University of Madrid.           --
--                                                                          --
------------------------------------------------------------------------------
package body System.Tracing_Hooks with
  Preelaborate
is

   type Interrupt_Hook_Array is array (Interrupt_Event) of Interrupt_Hook
   with Atomic_Components;

   type Task_Hook_Array is array (Task_Event) of Task_Hook
   with Atomic_Components;

   Interrupt_Hooks : Interrupt_Hook_Array := (others => null);
   Task_Hooks      : Task_Hook_Array      := (others => null);

   ----------------------------
   -- Install_Interrupt_Hook --
   ----------------------------

   procedure Install_Interrupt_Hook
     (Event : Interrupt_Event;
      Hook  : Interrupt_Hook)
   is
   begin
      if Tracing_Enabled then
         Interrupt_Hooks (Event) := Hook;
      end if;
   end Install_Interrupt_Hook;

   -------------------------
   -- Call_Interrupt_Hook --
   -------------------------

   procedure Call_Interrupt_Hook
     (Event : Interrupt_Event;
      ID    : Positive)
   is
      Hook : Interrupt_Hook;
   begin
      if Tracing_Enabled then
         Hook := Interrupt_Hooks (Event);

         if Hook /= null then
            Hook.all (ID);
         end if;
      end if;
   end Call_Interrupt_Hook;

   -----------------------
   -- Install_Task_Hook --
   -----------------------

   procedure Install_Task_Hook
     (Event : Task_Event;
      Hook  : Task_Hook)
   is
   begin
      if Tracing_Enabled then
         Task_Hooks (Event) := Hook;
      end if;
   end Install_Task_Hook;

   --------------------
   -- Call_Task_Hook --
   --------------------

   procedure Call_Task_Hook
     (Event : Task_Event;
      ID    : Task_ID)
   is
      Hook : Task_Hook;
   begin
      if Tracing_Enabled then
         Hook := Task_Hooks (Event);

         if Hook /= null then
            Hook.all (ID);
         end if;
      end if;
   end Call_Task_Hook;

end System.Tracing_Hooks;
