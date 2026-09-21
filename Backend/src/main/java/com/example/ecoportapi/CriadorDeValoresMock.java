package com.example.ecoportapi;

import com.example.ecoportapi.Models.Enums.TipoDeUnidade;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import java.time.LocalTime;

@Component
public class CriadorDeValoresMock implements CommandLineRunner {

   private final UnidadeRepository unidadeRepository;


    public CriadorDeValoresMock(UnidadeRepository unidadeRepository) {
        this.unidadeRepository = unidadeRepository;
    }

    @Override
    public void run(String... args){
        if (unidadeRepository.count() == 0){
            UnidadeDeConservacao unidade = new UnidadeDeConservacao();


            unidade.setNome("Parque Estadual da Serra Verde");
            unidade.setLocalizacao("Santa Bárbara d'Oeste - SP");
            //unidade.setLocalizacao("Rua Lisboa Filho, 765, Jardim Charles Manoel, Santa Barbara D'oeste, Brasil");
            unidade.setTipoDeUnidade(TipoDeUnidade.PARQUE_NACIONAL);
            unidade.setBioma("Mata Atlântica");

            unidade.setAreaTotal(4820.50);
            unidade.setAreaRegularizada(4380.20);
            unidade.setAreaPreservada(4215.80);
            unidade.setAreaMonitorada(3890.00);

            unidade.setPontosMonitorados(42);
            unidade.setPontosPrevistos(50);

            unidade.setAreaBasePorCorredor(500.0);
            unidade.setQuantidadeCorredores(8);

            unidade.setQuantidadeEspecies(327);
            unidade.setQuantidadeEspeciesEsperadas(360);

            unidade.setQualidadeAgua(86.5);
            unidade.setQualidadeSolo(91.2);
            unidade.setGestaoResiduos(78.0);

            unidade.setTelefone("(19) 3456-7821");
            unidade.setHoraAbertura(LocalTime.of(8, 0));
            unidade.setHoraFechamento(LocalTime.of(17, 0));

            unidadeRepository.save(unidade);
        }
    }
}
