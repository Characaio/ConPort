package com.example.ecoportapi;

import com.example.ecoportapi.Exceptions.SupervisorNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.*;
import com.example.ecoportapi.Models.Enums.*;
import com.example.ecoportapi.Repositories.*;
import jakarta.transaction.Transactional;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Component
public class CriadorDeValoresMock implements CommandLineRunner {

    private final UnidadeRepository unidadeRepository;
    private final ReportRepository reportRepository;
    private final UsuarioRepository usuarioRepository;
    private final SupervisorRepository supervisorRepository;
    private final MissaoRepository missaoRepository;

    public CriadorDeValoresMock(
            UnidadeRepository unidadeRepository,
            ReportRepository reportRepository,
            UsuarioRepository usuarioRepository,
            SupervisorRepository supervisorRepository, MissaoRepository missaoRepository) {
        this.unidadeRepository = unidadeRepository;
        this.reportRepository = reportRepository;
        this.usuarioRepository = usuarioRepository;
        this.supervisorRepository = supervisorRepository;
        this.missaoRepository = missaoRepository;
    }

    private void CriarUnidade(){

        if (unidadeRepository.count() > 0){
            return;
        }
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

        unidade.setTelefone("1934567821");
        unidade.setHoraAbertura(LocalTime.of(8, 0));
        unidade.setHoraFechamento(LocalTime.of(17, 0));

        unidadeRepository.save(unidade);

    }

    private void CriarUsuariosBase(){
        if (usuarioRepository.count() > 0){
            return;
        }
        Usuario usuario1 = new Usuario();

        usuario1.setNome("Celso portioli");
        usuario1.setDataNasc(LocalDate.of(2001,9,11));
        usuario1.setEmail("gmail@WorldTradeCenter.com");
        usuario1.setSenha("Osama Bin Laden");
        usuario1.setConfiavel(true);
        usuario1.setCidade("Santa Barbara D'oeste");
        usuario1.setEstado("São paulo");
        usuario1.setXP(0);
        usuario1.setLevel(10);
        usuario1.setMoedas(69420);

        Usuario usuario2 = new Usuario();

        usuario2.setNome("Tocha Humana");
        usuario2.setDataNasc(LocalDate.of(1939,8,15));
        usuario2.setEmail("JohnyStorms@gmail.com");
        usuario2.setSenha("QuartetoFantastico4444");
        usuario2.setConfiavel(false);
        usuario2.setCidade("Santa Barbara D'oeste");
        usuario2.setEstado("São paulo");
        usuario2.setXP(10);
        usuario2.setLevel(0);
        usuario2.setMoedas(5);

        usuarioRepository.saveAll(
                List.of(usuario1,usuario2)
        );
    }

    private void CriarSupervisor(){
        if (supervisorRepository.count() > 0){
            return;
        }
        SupervisorDeUnidade supervisorDeUnidade = new SupervisorDeUnidade();

        supervisorDeUnidade.setUnidade(
                unidadeRepository.findById(1L)
                        .orElseThrow(
                                () -> new UnidadeNaoEncontrada("Unidade Não Encontrada")
                        )
        );
        supervisorDeUnidade.setUsuario(
                usuarioRepository.findById(1L)
                        .orElseThrow(
                                () -> new UsuarioNaoEncontrado("Usuario Não Encontrada")
                        )
        );

        supervisorRepository.save(supervisorDeUnidade);
    }

    private void CriarReport(){
        if (reportRepository.count() > 0){
            return;
        }
            Report report1 = new Report();
            Report report2 = new Report();
            SupervisorDeUnidade supervisorDeUnidade = supervisorRepository.findById(1L)
                    .orElseThrow(
                            () -> new SupervisorNaoEncontrado("Supervisor Não Encontrado")
                    );
            UnidadeDeConservacao unidadeDeConservacao = unidadeRepository.findById(1L)
                            .orElseThrow(
                                    () -> new UnidadeNaoEncontrada("Unidade Não Encontrada")
                            );
            Usuario usuario = usuarioRepository.findById(2L)
                            .orElseThrow(
                                    () -> new UsuarioNaoEncontrado("Usuario Não Encontrado")
                            );
            report1.setUnidade(unidadeDeConservacao);
            report2.setUnidade(unidadeDeConservacao);

            report1.setUsuario(usuario);
            report2.setUsuario(usuario);

            report1.setTipo(TipoDeIncidente.QUEIMADA);
            report2.setTipo(TipoDeIncidente.ANIMAL_EXOTICO);

            report1.setSupervisor(supervisorDeUnidade);
            report2.setSupervisor(supervisorDeUnidade);

            report1.setDescricao("Queimada de pequena escala detectada");
            report2.setDescricao("Familia de Javali avistado rondando as trilhas principais");

            report1.setDataDoOcorrido(LocalDateTime.of(2026,3,24, 14,35,49));
            report2.setDataDoOcorrido(LocalDateTime.of(2026,3,25, 16,15,20));

            report1.setDataDaAnalisa(LocalDateTime.of(2026,3,24, 16,25,6));
            report2.setDataDaAnalisa(LocalDateTime.of(2026,3,30, 10,26,24));

            report1.setStatus(StatusReport.NEGADO);
            report1.setMotivoDaNegacao("Report falso sobre a ocorrencia, a queimada era falsa");

            report2.setStatus(StatusReport.TRATADO);

            reportRepository.saveAll(List.of(report1,report2));
    }

    private Missao criar(
            Usuario usuario,
            String titulo,
            String descricao,
            TipoMissao tipo,
            int meta,
            int recompensaXP,
            int recompensaMoedas,
            LocalDateTime inicio,
            LocalDateTime fechamento
    ) {

        Missao missao = new Missao();

        missao.setUsuario(usuario);
        missao.setTitulo(titulo);
        missao.setDescricao(descricao);
        missao.setTipoDeMissao(tipo);
        missao.setStatusMissao(StatusMissao.DISPONIVEL);

        missao.setMeta(meta);
        missao.setProgresso(0);

        missao.setXpRecompensa(recompensaXP);
        missao.setMoedaRecompensa(recompensaMoedas);

        missao.setTempoDeInicio(inicio);
        missao.setTempoFechamento(fechamento);

        return missao;
    }

    @Transactional
    public void CriarMissoes() {

        Usuario usuario = usuarioRepository.findById(2L)
                .orElseThrow(
                        () -> new UsuarioNaoEncontrado("Usuario não encontrado")
                );

        LocalDateTime inicio = LocalDateTime.now();

        // Prazo de 7 dias
        LocalDateTime fechamento = inicio.plusDays(1);

        //2 missões de recicar
        Missao reciclar1 = criar(
                usuario,
                "Separar para Reciclar",
                "Separe corretamente materiais recicláveis dos resíduos comuns e encaminhe-os para a coleta adequada.",
                TipoMissao.RECICLAR,
                5,
                50,
                30,
                inicio,
                fechamento
        );
        Missao reciclar2 = criar(
                usuario,
                "Reciclagem Consciente",
                "Separe e encaminhe diferentes tipos de materiais recicláveis para a destinação correta.",
                TipoMissao.RECICLAR,
                10,
                80,
                50,
                inicio,
                fechamento
        );

        //2 missões de plantar
        Missao plantar1 = criar(
                usuario,
                "Plante uma Nova Vida",
                "Plante uma muda ou cuide de uma planta, contribuindo para o aumento da vegetação.",
                TipoMissao.PLANTAR,
                1,
                60,
                40,
                inicio,
                fechamento
        );
        Missao plantar2 = criar(
                usuario,
                "Pequeno Bosque",
                "Plante e cuide de novas mudas em um espaço apropriado.",
                TipoMissao.PLANTAR,
                3,
                120,
                80,
                inicio,
                fechamento
        );

        //2 missões de reutilizar
        Missao reutilizar1 = criar(
                usuario,
                "Dê uma Nova Utilidade",
                "Reutilize um objeto que seria descartado, encontrando uma nova função para ele.",
                TipoMissao.REUTILIZAR,
                2,
                50,
                30,
                inicio,
                fechamento
        );
        Missao reutilizar2 = criar(
                usuario,
                "Menos Descarte",
                "Encontre novas formas de utilizar objetos que normalmente seriam descartados.",
                TipoMissao.REUTILIZAR,
                5,
                100,
                70,
                inicio,
                fechamento
        );

        missaoRepository.saveAll(List.of(
                reciclar1,
                reciclar2,
                plantar1,
                plantar2,
                reutilizar1,
                reutilizar2
        ));
    }

    @Override
    public void run(String... args){
        CriarUnidade();
        CriarUsuariosBase();
        CriarSupervisor();
        CriarReport();
        CriarMissoes();
    }
}
