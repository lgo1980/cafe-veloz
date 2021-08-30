%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Café veloz - parcial
% NOMBRE: Leonardo Olmedo - lgo1980
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
Necesitamos desarrollar una aplicación para una conocida empresa que hace los controles antidóping del fútbol
argentino. Tenemos la siguiente información:
*/
% jugadores conocidos
jugador(maradona).
jugador(chamot).
jugador(balbo).
jugador(caniggia).
jugador(passarella).
jugador(pedemonti).
jugador(basualdo).

% relaciona lo que toma cada jugador
tomo(maradona, sustancia(efedrina)).
tomo(maradona, compuesto(cafeVeloz)).
tomo(caniggia, producto(cocacola, 2)).
tomo(chamot, compuesto(cafeVeloz)).
tomo(balbo, producto(gatoreit, 2)).
tomo(passarella,Cosa):-
  not((tomo(maradona,Cosa))).
tomo(pedemonti,Cosa):-
  tomo(maradona,Cosa).
tomo(pedemonti,Cosa):-
  tomo(chamot,Cosa).
% relaciona la máxima cantidad de un producto que 1 jugador puede ingerir
maximo(cocacola, 3). 
maximo(gatoreit, 1).
maximo(naranju, 5).

% relaciona las sustancias que tiene un compuesto
composicion(cafeVeloz, [efedrina, ajipupa, extasis, whisky, cafe]).

% sustancias prohibidas por la asociación
sustanciaProhibida(efedrina). 
sustanciaProhibida(cocaina).
/*
Se pide:
1) Hacer lo que sea necesario para incorporar los siguientes conocimientos:
*/
%   a. passarella toma todo lo que no tome Maradona
%b. pedemonti toma todo lo que toma chamot y lo que toma Maradona
%c. basualdo no toma coca cola
% no hay que hacer nada por universo cerrado
/*
2) Definir el predicado puedeSerSuspendido/1 que relaciona si un jugador puede ser
suspendido en base a lo que tomó. El predicado debe ser inversible.*/
%   a. un jugador puede ser suspendido si tomó una sustancia que está prohibida
prohibida(sustancia(Sustancia)):-
  sustanciaProhibida(Sustancia).
%   b. un jugador puede ser suspendido si tomó un compuesto que tiene una sustancia
%   prohibida
prohibida(compuesto(Compuesto)):-
  composicion(Compuesto,Sustancias),
  member(Sustancia,Sustancias),
  sustanciaProhibida(Sustancia).
%   c. o un jugador puede ser suspendido si tomó una cantidad excesiva de un producto
%   (más que el máximo permitido):
prohibida(producto(Producto,Cantidad)):-
  maximo(Producto, Maximo),
  Maximo < Cantidad. 

/*
X = maradona ; => tomó efedrina y cafeVeloz
X = chamot ; => tomó cafeVeloz
X = balbo ; => tomó 2 gatoreits! > 1
*/
puedeSerSuspendido(Jugador):-
  distinct(Jugador,tomo(Jugador,Sustancia)),
  prohibida(Sustancia).

%3) Si agregamos los siguientes hechos:
amigo(maradona, caniggia).
amigo(caniggia, balbo).
amigo(balbo, chamot).
amigo(balbo, pedemonti).
/*
Defina el predicado malaInfluencia/2 que relaciona dos jugadores, si ambos pueden ser
suspendidos y además se conocen. Un jugador conoce a sus amigos y a los conocidos de sus
amigos.*/
malaInfluencia(Persona, OtraPersona):-
  puedeSerSuspendido(Persona),
  puedeSerSuspendido(OtraPersona),
  conocidos(Persona, OtraPersona).

conocidos(Persona, OtraPersona):-
  amigo(Persona,OtraPersona).
conocidos(Persona, OtraPersona):-
  amigo(Persona,Amigo),
  conocidos(Amigo,OtraPersona).

/*Quien = chamot ;
Quien = balbo ;
Quien = pedemonti ; (con el agregado del punto 1)
(Maradona no es mala influencia para Caniggia porque no lo podrían suspender)*/

%4) Agregamos ahora la lista de médicos que atiende a cada jugador
atiende(cahe, maradona).
atiende(cahe, chamot).
atiende(cahe, balbo).
atiende(zin, caniggia).
atiende(cureta, pedemonti).
atiende(cureta, basualdo).
/*
Definir el predicado chanta/1, que se verifica para los médicos que sólo atienden a jugadores que
podrían ser suspendidos. El predicado debe ser inversible.
? chanta(X).
X = cahe
*/
chanta(Medico):- 
  medico(Medico),
  forall(atiende(Medico,Jugador),puedeSerSuspendido(Jugador)).

medico(Medico):-
  distinct(Medico,atiende(Medico,_)).

%5) Si conocemos el nivel de alteración en sangre de una sustancia con los siguientes hechos
nivelFalopez(efedrina, 10).
nivelFalopez(cocaina, 100).
nivelFalopez(extasis, 120).
nivelFalopez(omeprazol, 5).

%Definir el predicado cuantaFalopaTiene/2, que relaciona el nivel de alteración en sangre que tiene
%un jugador, considerando que:
/*
- todos los productos (como la coca cola y el gatoreit), no tienen nivel de alteración (asumir 0)
- las sustancias tienen definidas el nivel de alteración en base al predicado nivelFalopez/2
- los compuestos suman los niveles de falopez de cada sustancia que tienen.
El predicado debe ser inversible en ambos argumentos. Ej: el cafeVeloz tiene nivel 130 (120 del
éxtasis + 10 de la efedrina, las sustancias que no tienen nivel se asumen 0).
?- cuantaFalopaTiene(Jugador, Cantidad).
Jugador = maradona, Cantidad = 140 ;  tomó efedrina (10) y cafeVeloz (130)
Jugador = chamot, Cantidad = 130 ;  tomó cafeVeloz (130)
*/
calcularNivelFalopa(Jugador, Nivel):-
  tomo(Jugador, Sustancia), 
  calcularNivel(Sustancia,Nivel).


calcularNivel(producto(_,_), 0).
calcularNivel(sustancia(Sustancia), NivelSustancia):-
  nivelFalopez(Sustancia,NivelSustancia).
calcularNivel(compuesto(Compuesto), NivelSustancia):-
  composicion(Compuesto,Sustancias),
  member(Sustancia,Sustancias),
  nivelFalopez(Sustancia,NivelSustancia).

cuantaFalopaTiene(Jugador, Cantidad):-
  jugador(Jugador),
  findall(Nivel,calcularNivelFalopa(Jugador, Nivel),Niveles),
  sum_list(Niveles, Cantidad).

/*
  6) Definir el predicado medicoConProblemas/1, que se satisface si un médico atiende a más de 3
jugadores conflictivos, esto es
- que pueden ser suspendidos o
- que conocen a Maradona (según el punto 3, donde son amigos directos o conocen a
alguien que es amigo de él). El predicado debe ser inversible.
? medicoConProblemas(X).
X = cahe
*/
medicoConProblemas(Medico):-
  medico(Medico),
  findall(Jugador,atiendeJugadorConflictivo(Medico,Jugador),Jugadores),
  length(Jugadores,Cantidad),
  Cantidad >= 3.

atiendeJugadorConflictivo(Medico,Jugador):-
  atiende(Medico,Jugador),
  esConflictivo(Jugador).
esConflictivo(Jugador):-
  puedeSerSuspendido(Jugador).
esConflictivo(Jugador):-
  conocidos(Jugador,maradona).

/*
7- Definir el predicado programaTVFantinesco/1, que permite armar una combinatoria de
jugadores que pueden ser suspendidos. Ej:
? programaTVFantinesco(Lista)
Lista = []
Lista = [maradona]
Lista = [maradona, chamot]
Lista = [maradona, chamot, balbo]
etc. No importa si aparece más de una vez Maradona en su solución.
*/
programaTVFantinesco(Lista):-
  findall(Jugador,puedeSerSuspendido(Jugador),Jugadores),
  combinarJugadores(Jugadores,Lista).

combinarJugadores([],[]).
combinarJugadores([Jugador|Jugadores],[Jugador|JugadoresPosibles]):-
  combinarJugadores(Jugadores,JugadoresPosibles).
combinarJugadores([_|Jugadores],JugadoresPosibles):-
  combinarJugadores(Jugadores,JugadoresPosibles).
  
:- begin_tests(utneanos).

  test(maradona_es_suspendido_por_efedrina, set(Persona=[maradona,chamot,balbo,pedemonti])):-
    puedeSerSuspendido(Persona).
  test(maradona_es_suspendido_por_efedrina, fail):-
    puedeSerSuspendido(caniggia).
  test(personas_que_son_mala_influencia, set(OtraPersona=[chamot,balbo,pedemonti])):-
    malaInfluencia(maradona,OtraPersona).
  test(maradona_no_es_mala_influencia_para_caniggia, fail):-
    malaInfluencia(maradona,caniggia).
  test(medico_que_puede_ser_chanta, set(Medico=[cahe])):-
    chanta(Medico).
  test(cuanta_falopa_tiene_un_jugador, nondet):-
    cuantaFalopaTiene(maradona, 140).
  test(medico_que_atiende_a_mas_de_3_jugadores_conflictivos, set(Medico=[cahe])):-
    medicoConProblemas(Medico).
  test(jugadores_que_pueden_ser_suspendidos, set(Jugadores=[[],[balbo],[balbo,pedemonti],[chamot],[chamot,balbo],[chamot,balbo,pedemonti],[chamot,pedemonti],[maradona],[maradona,balbo],[maradona,balbo,pedemonti],[maradona,chamot],[maradona,chamot,balbo],[maradona,chamot,balbo,pedemonti],[maradona,chamot,pedemonti],[maradona,pedemonti],[pedemonti]])):-
    programaTVFantinesco(Jugadores).

:- end_tests(utneanos).