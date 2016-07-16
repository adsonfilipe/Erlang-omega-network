% Autor: Adson Filipe Vieira da Silva - 7960922

-module(omega).
-export([init/2, send/1, stage1/0, stage2/0, stage3/0, recv/0]).

init(Origin,Destination) ->
	
	% Cria os novos processos. A priori, cada novo corresponde a um switch da rede. São 12 switches.
	% Existem 8 processos adicionais que irão printar a resposta final, portanto apenas estes últimos processos
	% Não fazem roteamento em si.
	global:register_name(pid11,spawn(omega,recv,[])),
    global:register_name(pid12,spawn(omega,recv,[])),
  	global:register_name(pid13,spawn(omega,recv,[])),
  	global:register_name(pid14,spawn(omega,recv,[])),
    global:register_name(pid15,spawn(omega,recv,[])),
    global:register_name(pid16,spawn(omega,recv,[])),
    global:register_name(pid17,spawn(omega,recv,[])),
    global:register_name(pid18,spawn(omega,recv,[])),
    global:register_name(pid21,spawn(omega,stage1,[])),
    global:register_name(pid22,spawn(omega,stage1,[])),
    global:register_name(pid23,spawn(omega,stage1,[])),
    global:register_name(pid24,spawn(omega,stage1,[])),
    global:register_name(pid31,spawn(omega,stage2,[])),
    global:register_name(pid32,spawn(omega,stage2,[])),
    global:register_name(pid33,spawn(omega,stage2,[])),
    global:register_name(pid34,spawn(omega,stage2,[])),
    global:register_name(pid41,spawn(omega,stage3,[])),
    global:register_name(pid42,spawn(omega,stage3,[])),
    global:register_name(pid43,spawn(omega,stage3,[])),
    global:register_name(pid44,spawn(omega,stage3,[])),

    % Mensagem padrão a ser enviada
	Msg = "olah",


	% Converte a entrada (origem) Decimal para Binária
	if
		Origin =:= 0 ->
			Org = <<0:1,0:1,0:1>>;
		Origin =:= 1 ->
			Org = <<0:1,0:1,1:1>>;
		Origin =:= 2 ->
			Org = <<0:1,1:1,0:1>>;
		Origin =:= 3 ->
			Org = <<0:1,1:1,1:1>>;
		Origin =:= 4 ->
			Org = <<1:1,0:1,0:1>>;
		Origin =:= 5 ->
			Org = <<1:1,0:1,1:1>>;
		Origin =:= 6 ->
			Org = <<1:1,1:1,0:1>>;
		Origin =:= 7 ->
			Org = <<1:1,1:1,1:1>>
	end,

	% Converte a entrada (destino) Decimal para Binária
	if
		Destination =:= 0 ->
			Dest = <<0:1,0:1,0:1>>;
		Destination =:= 1 ->
			Dest = <<0:1,0:1,1:1>>;
		Destination =:= 2 ->
			Dest = <<0:1,1:1,0:1>>;
		Destination =:= 3 ->
			Dest = <<0:1,1:1,1:1>>;
		Destination =:= 4 ->
			Dest = <<1:1,0:1,0:1>>;
		Destination =:= 5 ->
			Dest = <<1:1,0:1,1:1>>;
		Destination =:= 6 ->
			Dest = <<1:1,1:1,0:1>>;
		Destination =:= 7 ->
			Dest = <<1:1,1:1,1:1>>
	end,

	% Função que determinará qual o switch inicial da rota
	send({Msg, Org, Dest}).

send(Datagram) ->
  Orig = element(2,Datagram),

  Pid21 = global:whereis_name(pid21),
  Pid22 = global:whereis_name(pid22),
  Pid23 = global:whereis_name(pid23),
  Pid24 = global:whereis_name(pid24),

% Determina o Switch inicial da rota e faz o envio para o processo correspondente.
if
	Orig =:= <<0:1,0:1,0:1>> ->
		% {0, -1, -1, -1} essa tupla armazenará o caminho percorrido (rota).
		Pid21 ! {Datagram, {0, -1, -1, -1}};
	Orig =:= <<1:1,0:1,0:1>> ->
		Pid21 ! {Datagram, {1, -1, -1, -1}};
	Orig =:= <<0:1,0:1,1:1>> ->
		Pid22 ! {Datagram, {2, -1, -1, -1}};
	Orig =:= <<1:1,0:1,1:1>> ->
		Pid22 ! {Datagram, {3, -1, -1, -1}};
	Orig =:= <<0:1,1:1,0:1>> ->
		Pid23 ! {Datagram, {4, -1, -1, -1}};
	Orig =:= <<1:1,1:1,0:1>> ->
		Pid23 ! {Datagram, {5, -1 ,-1, -1}};
	Orig =:= <<0:1,1:1,1:1>> ->
		Pid24 ! {Datagram, {6, -1 ,-1, -1}};
	Orig =:= <<1:1,1:1,1:1>> ->
		Pid24 ! {Datagram, {7, -1, -1, -1}}
end.

% Quatro processos executam esta função. Corresponde a parte funcional dos switches do estágio 1.
stage1() ->
	receive
		{Datagram, Path} ->
		Pid21 = global:whereis_name(pid21),
		Pid22 = global:whereis_name(pid22),
		Pid23 = global:whereis_name(pid23),
		Pid24 = global:whereis_name(pid24),
		Pid31 = global:whereis_name(pid31),
        Pid32 = global:whereis_name(pid32),
        Pid33 = global:whereis_name(pid33),
        Pid34 = global:whereis_name(pid34),

        Dest = element(3,Datagram),
        Orig = element(2,Datagram),

        % Extrai o primeiro bit da origem e do destino
        <<ElemOrig:1,_:1,_:1>> = Orig,
        <<ElemDest:1,_:1,_:1>> = Dest,

         Last = element(1, Path),

        if 
         	self() =:= Pid21 ->
         		if 
         			Last =:= 0, ElemOrig =:= ElemDest ->
         				% Envia a mensagem, origem, destino e o caminho feito até agora para o proximo switch
         				Pid31 ! {Datagram, setelement(2, Path, 8)};
         			Last =:= 1, ElemOrig =:= ElemDest ->
         				Pid32 ! {Datagram, setelement(2, Path, 10)};
         			Last =:= 0, ElemOrig =/= ElemDest ->
         				Pid32 ! {Datagram, setelement(2, Path, 10)};
         			Last =:= 1, ElemOrig =/= ElemDest ->
         				Pid31 ! {Datagram, setelement(2, Path, 8)}
         		end;
			self() =:= Pid22 ->
         		if 
         			Last =:= 2, ElemOrig =:= ElemDest ->
         				Pid33 ! {Datagram, setelement(2, Path, 12)};
         			Last =:= 3, ElemOrig =:= ElemDest ->
         				Pid34 ! {Datagram, setelement(2, Path, 14)};
         			Last =:= 2, ElemOrig =/= ElemDest ->
         				Pid34 ! {Datagram, setelement(2, Path, 14)};
         			Last =:= 3, ElemOrig =/= ElemDest ->
         				Pid33 ! {Datagram, setelement(2, Path, 12)}
				end;
			self() =:= Pid23 ->
         		if 
         			Last =:= 4, ElemOrig =:= ElemDest ->
         				Pid31 ! {Datagram, setelement(2, Path, 9)};
         			Last =:= 5, ElemOrig =:= ElemDest ->
         				Pid32 ! {Datagram, setelement(2, Path, 11)};
         			Last =:= 4, ElemOrig =/= ElemDest ->
         				Pid32 ! {Datagram, setelement(2, Path, 11)};
         			Last =:= 5, ElemOrig =/= ElemDest ->
         				Pid31 ! {Datagram, setelement(2, Path, 9)}
				end;
			self() =:= Pid24 ->
         		if 
         			Last =:= 6, ElemOrig =:= ElemDest ->
         				Pid33 ! {Datagram, setelement(2, Path, 13)};
         			Last =:= 7, ElemOrig =:= ElemDest ->
         				Pid34 ! {Datagram, setelement(2, Path, 15)};
         			Last =:= 6, ElemOrig =/= ElemDest ->
         				Pid34 ! {Datagram, setelement(2, Path, 15)};
         			Last =:= 7, ElemOrig =/= ElemDest ->
         				Pid33 ! {Datagram, setelement(2, Path, 13)}
				end
		end,

	stage1()
end.


% Quatro processos executam esta função. Corresponde a parte funcional dos switches do estágio 2.
stage2() ->
	receive
		{Datagram, Path} ->

		 Pid31 = global:whereis_name(pid31),
         Pid32 = global:whereis_name(pid32),
         Pid33 = global:whereis_name(pid33),
         Pid34 = global:whereis_name(pid34),
		 Pid41 = global:whereis_name(pid41),
         Pid42 = global:whereis_name(pid42),
         Pid43 = global:whereis_name(pid43),
         Pid44 = global:whereis_name(pid44),

         Dest = element(3,Datagram),
         Orig = element(2,Datagram),

         % Extrai o segundo bit da origem e do destino
        <<_:1,ElemOrig:1,_:1>> = Orig,
        <<_:1,ElemDest:1,_:1>> = Dest,

         Last = element(2, Path),

        if 
         	self() =:= Pid31 ->
         		if 
         			Last =:= 8, ElemOrig =:= ElemDest ->
         				% Envia a mensagem, origem, destino e o caminho feito até agora para o proximo switch
         				Pid41 ! {Datagram, setelement(3, Path, 16)};
         			Last =:= 9, ElemOrig =:= ElemDest ->
         				Pid42 ! {Datagram, setelement(3, Path, 18)};
         			Last =:= 8, ElemOrig =/= ElemDest ->
         				Pid42 ! {Datagram, setelement(3, Path, 18)};
         			Last =:= 9, ElemOrig =/= ElemDest ->
         				Pid41 ! {Datagram, setelement(3, Path, 16)}
         		end;
			self() =:= Pid32 ->
         		if 
         			Last =:= 10, ElemOrig =:= ElemDest ->
         				Pid43 ! {Datagram, setelement(3, Path, 20)};
         			Last =:= 11, ElemOrig =:= ElemDest ->
         				Pid44 ! {Datagram, setelement(3, Path, 22)};
         			Last =:= 10, ElemOrig =/= ElemDest ->
         				Pid44 ! {Datagram, setelement(3, Path, 22)};
         			Last =:= 11, ElemOrig =/= ElemDest ->
         				Pid43 ! {Datagram, setelement(3, Path, 20)}
				end;
			self() =:= Pid33 ->
         		if 
         			Last =:= 12, ElemOrig =:= ElemDest ->
         				Pid41 ! {Datagram, setelement(3, Path, 17)};
         			Last =:= 13, ElemOrig =:= ElemDest ->
         				Pid42 ! {Datagram, setelement(3, Path, 19)};
         			Last =:= 12, ElemOrig =/= ElemDest ->
         				Pid42 ! {Datagram, setelement(3, Path, 19)};
         			Last =:= 13, ElemOrig =/= ElemDest ->
         				Pid41 ! {Datagram, setelement(3, Path, 17)}
				end;
			self() =:= Pid34 ->
         		if 
         			Last =:= 14, ElemOrig =:= ElemDest ->
         				Pid43 ! {Datagram, setelement(3, Path, 21)};
         			Last =:= 15, ElemOrig =:= ElemDest ->
         				Pid44 ! {Datagram, setelement(3, Path, 23)};
         			Last =:= 14, ElemOrig =/= ElemDest ->
         				Pid44 ! {Datagram, setelement(3, Path, 23)};
         			Last =:= 15, ElemOrig =/= ElemDest ->
         				Pid43 ! {Datagram, setelement(3, Path, 21)}
				end
		end,

	stage2()
end.

% Quatro processos executam esta função. Corresponde a parte funcional dos switches do estágio 3.
stage3() ->
	receive
		{Datagram, Path} ->
		Pid41 = global:whereis_name(pid41),
        Pid42 = global:whereis_name(pid42),
        Pid43 = global:whereis_name(pid43),
        Pid44 = global:whereis_name(pid44),
        Pid11 = global:whereis_name(pid11),
        Pid12 = global:whereis_name(pid12),
      	Pid13 = global:whereis_name(pid13),
      	Pid14 = global:whereis_name(pid14),
      	Pid15 = global:whereis_name(pid15),
        Pid16 = global:whereis_name(pid16),
      	Pid17 = global:whereis_name(pid17),
      	Pid18 = global:whereis_name(pid18),

        Dest = element(3,Datagram),
        Orig = element(2,Datagram),

        <<_:1,_:1,ElemOrig:1>> = Orig,
        <<_:1,_:1,ElemDest:1>> = Dest,
        
		Last = element(3, Path),

        if 
         	self() =:= Pid41 ->
         		if 
         			Last =:= 16, ElemOrig =:= ElemDest ->
         				% Envia para o processo responsável por escever na standard output, mostrando o caminho percorrido e a mensagem
         				Pid11 ! {Datagram, setelement(4, Path, 24)};
         			Last =:= 17, ElemOrig =:= ElemDest ->
         				Pid12 ! {Datagram, setelement(4, Path, 25)};
         			Last =:= 16, ElemOrig =/= ElemDest ->
         				Pid12 ! {Datagram, setelement(4, Path, 25)};
         			Last =:= 17, ElemOrig =/= ElemDest ->
         				Pid11 ! {Datagram, setelement(4, Path, 24)}
         		end;
			self() =:= Pid42 ->
         		if 
         			Last =:= 18, ElemOrig =:= ElemDest ->
         				Pid13 ! {Datagram, setelement(4, Path, 26)};
         			Last =:= 19, ElemOrig =:= ElemDest ->
         				Pid14 ! {Datagram, setelement(4, Path, 27)};
         			Last =:= 18, ElemOrig =/= ElemDest ->
         				Pid14 ! {Datagram, setelement(4, Path, 27)};
         			Last =:= 19, ElemOrig =/= ElemDest ->
         				Pid13 ! {Datagram, setelement(4, Path, 26)}
				end;
			self() =:= Pid43 ->
         		if 
         			Last =:= 20, ElemOrig =:= ElemDest ->
         				Pid15 ! {Datagram, setelement(4, Path, 28)};
         			Last =:= 21, ElemOrig =:= ElemDest ->
         				Pid16 ! {Datagram, setelement(4, Path, 29)};
         			Last =:= 20, ElemOrig =/= ElemDest ->
         				Pid16 ! {Datagram, setelement(4, Path, 29)};
         			Last =:= 21, ElemOrig =/= ElemDest ->
         				Pid15 ! {Datagram, setelement(4, Path, 28)}
				end;
			self() =:= Pid44 ->
         		if 
         			Last =:= 22, ElemOrig =:= ElemDest ->
         				Pid17 ! {Datagram, setelement(4, Path, 30)};
         			Last =:= 23, ElemOrig =:= ElemDest ->
         				Pid18 ! {Datagram, setelement(4, Path, 31)};
         			Last =:= 22, ElemOrig =/= ElemDest ->
         				Pid18 ! {Datagram, setelement(4, Path, 31)};
         			Last =:= 23, ElemOrig =/= ElemDest ->
         				Pid17 ! {Datagram, setelement(4, Path, 30)}
				end
		end,
	stage3()
end.

recv() ->
		receive
			{Datagram, Path} ->
			io:format("Mensagem = ~p~n",[element(1, Datagram)]),
			io:format("Caminho = ~p~n",[Path]),
		recv()
end.

