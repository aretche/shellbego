{SHELLBEGO - BRACCO ESCALANTE GARCIA OBELAR
SHELLBEGO is Copyright (C) 2014-2015 Free Software Foundation, Inc.	
SHELLBEGO es un intérprete primitivo de lenguajes de comandos que ejecuta órdenes leídas de la entrada estándar.
SHELLBEGO fue desarrollada como trabajo final de la materia Sistemas Operativos FRCU - UTN.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    Also add information on how to contact you by electronic and paper mail.}
UNIT TDAREGISTROPROCESO;
INTERFACE

TYPE
Proceso=Record
	        PID:LONGINT;
	        NUMEROTRABAJO:CARDINAL;
	        NOMBRE:STRING;
	        ESTADO,OPCION:CHAR;
        END;

FUNCTION CrearProceso(PID:CARDINAL;NUMEROTRABAJO:CARDINAL;NOMBRE:STRING;ESTADO,OPCION:CHAR):PROCESO;
FUNCTION NumeroTrabajo(NODO:PROCESO):CARDINAL;
FUNCTION DevolverPid(NODO:PROCESO):CARDINAL;
FUNCTION EstadoProceso(NODO:PROCESO):CHAR;
FUNCTION NombreProceso(NODO:PROCESO):STRING;
FUNCTION Opcion(NODO:PROCESO):CHAR;
FUNCTION CambiarEstado(VAR NODO:PROCESO;ESTADO:CHAR):PROCESO; 
FUNCTION CambiarOpcion(VAR NODO:PROCESO;OPCION:CHAR):PROCESO;

IMPLEMENTATION
FUNCTION CrearProceso(PID:CARDINAL;NUMEROTRABAJO:CARDINAL;NOMBRE:STRING;ESTADO,OPCION:CHAR):PROCESO;
VAR
P:Proceso;
BEGIN
	 P.PID:=PID;
	 P.NUMEROTRABAJO:=NUMEROTRABAJO;
	 P.NOMBRE:=NOMBRE;
	 P.ESTADO:=ESTADO;
	 P.OPCION:=OPCION;
	 CrearProceso:=P;
END;

FUNCTION NumeroTrabajo(NODO:PROCESO):CARDINAL;
BEGIN
	 NumeroTrabajo:=NODO.NUMEROTRABAJO;
END;

FUNCTION DevolverPid(NODO:PROCESO):CARDINAL;
BEGIN
	 DevolverPid:=NODO.PID;
END;

FUNCTION EstadoProceso(NODO:PROCESO):CHAR;
BEGIN
	 EstadoProceso:=NODO.ESTADO;
END;

FUNCTION NombreProceso(NODO:PROCESO):STRING;
BEGIN
	 NombreProceso:=NODO.NOMBRE;
END;

FUNCTION Opcion(NODO:PROCESO):CHAR;
BEGIN
	 Opcion:=NODO.OPCION;
END;

FUNCTION CambiarEstado(VAR NODO:PROCESO;ESTADO:CHAR):PROCESO;
BEGIN
	 NODO.ESTADO:=ESTADO;
	 CambiarEstado:=NODO;
END;

FUNCTION CambiarOpcion(VAR NODO:PROCESO;OPCION:CHAR):PROCESO;
BEGIN
	 NODO.OPCION:=OPCION;
	 CambiarOpcion:=NODO;
END;

END.
