package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Request.ImagemProcessada;
import com.example.ecoportapi.DTOs.Request.LocalizacaoDTO;
import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportStatusAnalise;
import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Exceptions.ReportNaoEncontrado;
import com.example.ecoportapi.Exceptions.SupervisorNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.*;
import com.example.ecoportapi.Models.Enums.*;
import com.example.ecoportapi.Repositories.ReportRepository;
import com.example.ecoportapi.Repositories.SupervisorRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAmount;
import java.util.*;

@Service
public class ReportService {

    private final ReportRepository reportRepository;
    private final UnidadeRepository unidadeRepository;
    private final UsuarioRepository usuarioRepository;
    private final SupervisorRepository supervisorRepository;
    private final ImagemService imagemService;

    public ReportService(ReportRepository reportRepository, UnidadeRepository unidadeRepository, UsuarioRepository usuarioRepository, SupervisorRepository supervisorRepository, ImagemService imagemService) {
        this.reportRepository = reportRepository;
        this.unidadeRepository = unidadeRepository;
        this.usuarioRepository = usuarioRepository;
        this.supervisorRepository = supervisorRepository;
        this.imagemService = imagemService;
    }

    public ReportExpandidoDTO PegarReportCompleto(Long id){
        Report report = reportRepository.findById(id)
                .orElseThrow(
                        () -> new ReportNaoEncontrado("Report Nao Encontrado")
                );

        return new ReportExpandidoDTO(report);
    }
    public ReportResumidoDTO PegarReportResumido(Long id){
        return new ReportResumidoDTO(reportRepository.findById(id)
                .orElseThrow(
                        () -> new ReportNaoEncontrado("Report Nao Encontrado")
                )
        );
    }

    private int CalcularConfianca(Report novoReport, Report reportExistente){

        int confianca = 0;

        if (novoReport.getTipo().equals(reportExistente.getTipo())){
            confianca += 25;
        } else{
            confianca -= 15;
        }

        if (!novoReport.getLocalizacaoOrigem().equals(LocalizacaoOrigem.NAO_INFORMADA)){
            confianca += CalcularConfiancaLocalizacao(novoReport,reportExistente);
        }

        confianca += CalcularConfiancaData(novoReport,reportExistente);

        return confianca;
    }

    public List<ReportResumidoDTO> PegarReportsDaUnidade(Long unidadeId){
        return reportRepository.findAllByUnidade_Id(unidadeId)
                .stream().map(ReportResumidoDTO::new).toList();
    }

    public ResponseEntity<?> PostarReport(
            ReportCreateDTO reportDTO,
            LocalizacaoDTO localizacaoDTO,
            List<MultipartFile> imagens,
            Long unidadeId) throws IOException {
        Report report = CriarReport(reportDTO,localizacaoDTO,imagens, unidadeId);

        if (VerificarReportDuplicado(report)){
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Report ja existe");
        }

        return ResponseEntity.status(HttpStatus.CREATED).body(
                new ReportExpandidoDTO(reportRepository.save(report))
        );
    }

    public ReportExpandidoDTO PostarAnalise(Long id, ReportStatusAnalise reportStatusAnalise){
        Report report = reportRepository.findById(id)
                .orElseThrow(
                        () -> new ReportNaoEncontrado("Report Não Encontrado")
                );
        SupervisorDeUnidade supervisor = supervisorRepository.findById(reportStatusAnalise.SupervisorId())
                        .orElseThrow(
                                () -> new SupervisorNaoEncontrado("Supervisor Não Encontrado"));
        report.setStatus(
                StatusReport.StringParaTipo(reportStatusAnalise.Status())
        );
        report.setDataDaAnalisa(LocalDateTime.now());
        report.setSupervisor(supervisor);
        reportRepository.save(report);

        return new ReportExpandidoDTO(report);
    }

    private Report CriarReport(
            ReportCreateDTO reportDTO,
            LocalizacaoDTO localizaoDTO,
            List<MultipartFile> imagens,
            Long unidadeId) throws IOException {
        Report report = new Report();
        List<ImagemProcessada> imagensProcessadas = imagemService.SalvarImagens(imagens);
        UnidadeDeConservacao unidade = unidadeRepository.findById(unidadeId)
                .orElseThrow(() -> new UnidadeNaoEncontrada("Unidade não encontrada"));

        Usuario usuario = usuarioRepository.findById(reportDTO.UsuarioId())
                .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

        report.setUnidade(unidade);
        report.setUsuario(usuario);
        report.setDescricao(reportDTO.Descricao());
        report.setTipo(TipoDeIncidente.StringParaTipo(reportDTO.Tipo()));
        report.setDataDoOcorrido(LocalDateTime.parse(reportDTO.DataDoOcorrido()));
        report.setPrioridade(reportDTO.Prioridade());
        report.setStatus(StatusReport.PENDENTE);
        report.setLocalizacaoOrigem(LocalizacaoOrigem.NAO_INFORMADA);

        if (localizaoDTO != null){
            report.setLongitude(localizaoDTO.Longitude());
            report.setLatitude(localizaoDTO.Latitude());
            report.setLocalizacaoOrigem(localizaoDTO.Origem());
        } else {
            for (ImagemProcessada imagem : imagensProcessadas){
                if (imagem.Latitude() != null && imagem.Longitude() != null){
                    report.setLatitude(imagem.Latitude());
                    report.setLongitude(imagem.Longitude());
                    report.setLocalizacaoOrigem(LocalizacaoOrigem.IMAGEM_EXIF);
                    break;
                }
            }
        }
        List<String> imagensCaminho = imagensProcessadas
                .stream()
                .map(ImagemProcessada::NomeArquivo)
                .toList();
        report.setImagensAnexadas(imagensCaminho);
        return report;
    }
    private double CalcularDistancia(
            double latitude1,
            double longitude1,
            double latitude2,
            double longitude2) {

        final double RAIO_TERRA = 6371000; // metros

        double lat1 = Math.toRadians(latitude1);
        double lat2 = Math.toRadians(latitude2);

        double diferencaLatitude =
                Math.toRadians(latitude2 - latitude1);

        double diferencaLongitude =
                Math.toRadians(longitude2 - longitude1);

        double a = Math.sin(diferencaLatitude / 2)
                * Math.sin(diferencaLatitude / 2)
                + Math.cos(lat1)
                * Math.cos(lat2)
                * Math.sin(diferencaLongitude / 2)
                * Math.sin(diferencaLongitude / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return RAIO_TERRA * c;
    }

    private Integer CalcularConfiancaLocalizacao(Report novo, Report existente) {

        if (novo.getLatitude() == null ||
            novo.getLongitude() == null ||
            existente.getLatitude() == null ||
            existente.getLongitude() == null) {

            return 0;
        }

        double distancia = CalcularDistancia(
                novo.getLatitude(),
                novo.getLongitude(),
                existente.getLatitude(),
                existente.getLongitude()
        );

        double confianca = 75 * Math.exp(-distancia / 300.0) - 30;

        return (int) Math.round(
                Math.max(-30, Math.min(45, confianca))
        );
    }

    private Integer CalcularConfiancaData(Report novoReport, Report reportExistente){
        LocalDateTime dataNova = novoReport.getDataDoOcorrido();
        LocalDateTime dataExistente = reportExistente.getDataDoOcorrido();

        Long segundos = Math.abs(
                Duration.between(dataNova,dataExistente)
                .toSeconds()
        );

        double confianca = 95 * Math.exp(-segundos / 1800.0) - 25;

        return (int) Math.round(
                Math.max(-25, Math.min(70, confianca))
        );
    }

    private boolean VerificarReportDuplicado(Report novoReport){
        List<Report> reportsPossiveis = reportRepository
                .BuscarReportsDoUsuarioNaUnidade(
                        novoReport.getUnidade().getId(),
                        novoReport.getUsuario().getId()
                );
        for (Report report : reportsPossiveis){
            Integer confianca = CalcularConfianca(novoReport,report);
            if (confianca >= 70){
                // ARRUMAR OS POSSIVEIS BUGS DEPOISSSSSSSS
                // #NÃO ESQUEÇA
                return true;
            }
        }
        return false;
    }
}
