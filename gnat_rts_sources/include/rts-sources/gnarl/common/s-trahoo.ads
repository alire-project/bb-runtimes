------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                   S Y S T E M . T R A C I N G _ H O O K S                --
--                                                                          --
--                                  S p e c                                 --
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

--  This package provides a way to register hooks that are called by the
--  runtime for various scheduling events.

package System.Tracing_Hooks with
  Preelaborate
is

   Tracing_Enabled : constant Boolean := False;
   --  Controls whether the tracing features in this package are enabled in
   --  the runtime.
   --
   --  When this is False, tracing is disabled and the runtime does not call
   --  any installed hooks.
   --
   --  To enable tracing, change this constant to True and rebuild the runtime.

   -----------------------
   -- Interrupt Tracing --
   -----------------------

   type Interrupt_Event is
     (Interrupt_Start,    --  Event at the start of the interrupt handler
      Interrupt_End);     --  Event at the end of the interrupt handler

   type Interrupt_Hook is access procedure (ID : Positive);

   procedure Install_Interrupt_Hook
     (Event : Interrupt_Event;
      Hook  : Interrupt_Hook);
   --  Install the procedure to be called on the specified interrupt event.
   --
   --  This has no effect when Tracing_Enabled is False.

   procedure Call_Interrupt_Hook
     (Event : Interrupt_Event;
      ID    : Positive)
   with
     Inline_Always;
   --  Call the currently installed handler for the specified interrupt event
   --
   --  This procedure has no effect when no handler is installed for the event,
   --  or when Tracing_Enabled is False.

   ------------------
   -- Task Tracing --
   ------------------

   type Task_Event is
     (Context_Switch_In,   --  Event when context switching to a task
      Context_Switch_Out); --  Event when context switching away from a task

   subtype Task_ID is System.Address;

   type Task_Hook is access procedure (ID : Task_ID);

   procedure Install_Task_Hook
     (Event : Task_Event;
      Hook  : Task_Hook);
   --  Install the procedure to be called on the specified task
   --  scheduling event.
   --
   --  This has no effect when Tracing_Enabled is False.

   procedure Call_Task_Hook
     (Event : Task_Event;
      ID    : Task_ID)
   with
     Inline_Always;
   --  Call the currently installed handler for the specified task event
   --
   --  This procedure has no effect when no handler is installed for the event,
   --  or when Tracing_Enabled is False.

end System.Tracing_Hooks;
