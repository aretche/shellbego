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

PROGRAM Shell;
USES VARIABLES,TDALISTA,TDALISTAPROCESOS,COMANDOS,HERRAMIENTAS,TDALISTAENTRADAS;

BEGIN
	 INICIALIZARVARIABLES;
	 CARGARLISTAENTRADAS(RUTA,LISTAENTRADAS);
	 WHILE(ENTRADA<>'miexit')do
	 Begin
		  PROMPT;
		  BorrarEspacios(ENTRADA);
		  LeerEntrada(ListaEntradas,Entrada);
		  IF(ENTRADA<>'')THEN
		  BEGIN
			   CREARLISTA(AUXILIAR,'');
			   TRANSFORMARENTRADA(ENTRADA,AUXILIAR);
			   IF ESTUBERIA(AUXILIAR)THEN
			   BEGIN
					LECTURAPIPE(AUXILIAR,LISTAENTRADAS,RUTA);
					EJECUTARPIPE(AUXILIAR,LISTAPROCESOS,LISTAENTRADAS);
			   END
			   ELSE
			   BEGIN
					AGREGARALHISTORIAL(LISTAENTRADAS,ENTRADA,RUTA);
					IF ESREDIRECCIONSALIDAESTANDAR(AUXILIAR)THEN
						EjecutarRedireccionSalidaEstandar(AUXILIAR,LISTAPROCESOS,LISTAENTRADAS)
					ELSE	
						INTERNOOEXTERNO(AUXILIAR,ListaProcesos,LISTAENTRADAS,'','');
			   END;
		  END;
	      CerrarLista(AUXILIAR,'');
	      ProcesosTerminados(ListaProcesos);
		  ActualizarListaProcesos(ListaProcesos);
	 end;
	 CerrarListaP(ListaProcesos,'');
END.


