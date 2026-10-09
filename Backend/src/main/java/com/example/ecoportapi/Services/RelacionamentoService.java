package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.AmizadeRespostaDTO;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import org.apache.tomcat.util.net.openssl.ciphers.Authentication;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RelacionamentoService {



    public List<UsuarioDTO> PesquisarPessoas(String termo){

    }

    public void EnviarPedidoAmizade(
            Authentication authentication,
            Long usarioAlvoId){

    }

    public void ResponderPedidoAmizade(
            Authentication authentication,
            AmizadeRespostaDTO amizadeRespostaDTO,
            Long pedidoAlvoId
    ){

    }

    public void ListarPedidos(
            Authentication authentication
    ){

    }

    public void DesfazerAmizade(
            Authentication authentication,
            Long usuarioAlvoId
    ){

    }

    public void ListarPedidosAmizade(
            Authentication authentication
    ) {

    }

    public void EnviarPedidoSeguido(
            Authentication authentication,
            Long usuarioAlvoId
    ) {

    }

    public void ResponderPedidoSeguidor(
            Authentication authentication,
            Long usuarioAlvoId
    ) {

    }

    public void PararDeSeguir(
            Authentication authentication,
            Long usuarioAlvoId
    ) {
        
    }
}
