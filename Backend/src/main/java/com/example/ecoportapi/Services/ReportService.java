package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Request.LocalizacaoDTO;
import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportStatusAnalise;
import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Exceptions.ReportNaoEncontrado;
import com.example.ecoportapi.Exceptions.SupervisorNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Enums.ImagemDadosParametros;
import com.example.ecoportapi.Models.Enums.ImagemOrigem;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import com.example.ecoportapi.Models.Report;
import com.example.ecoportapi.Models.SupervisorDeUnidade;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.ReportRepository;
import com.example.ecoportapi.Repositories.SupervisorRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
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
                .orElseThrow(() -> new ReportNaoEncontrado("Report Nao Encontrado"));

        return new ReportExpandidoDTO(report);
    }
    public ReportResumidoDTO PegarReportResumido(Long id){
        return reportRepository.PegarReportResumido(id);
    }

    public ResponseEntity<?> PostarReport(
            ReportCreateDTO reportDTO,
            LocalizacaoDTO localizacaoDTO,
            List<MultipartFile> imagens,
            Long unidadeId) throws IOException {
        Report report = CriarReport(reportDTO,localizacaoDTO,unidadeId);
        if (imagens != null){
            List<String> imagensCaminho = new ArrayList<>();
            Map<Integer,Map<ImagemDadosParametros,List<Object>>> ImagemInfo = imagemService.salvarImagens(imagens);
            for (Map<ImagemDadosParametros,List<Object>> imgInfo : ImagemInfo.values()){
                if (imgInfo.containsKey(ImagemDadosParametros.METADADOS) && localizacaoDTO == null){
                    List<Object> localização = List.copyOf(imgInfo.values());
                    double longitude = (double) localização.get(0);
                    double latitude = (double) localização.get(1);
                    report.setLongitude(longitude);
                    report.setLatitude(latitude);
                } else if (imgInfo.containsKey(ImagemDadosParametros.IMAGEMNOME)){
                    List<Object> caminhos = Collections.singletonList(imgInfo.values());
                    for (Object imagem: caminhos){
                        String caminho = imagem.toString();
                        imagensCaminho.add(caminho);
                    }
                    report.setImagensAnexadas(imagensCaminho);
                }
            }

        }
        return ResponseEntity.status(HttpStatus.CREATED).body(reportRepository.save(report));
    }

    public ReportExpandidoDTO PostarAnalise(Long id, ReportStatusAnalise reportStatusAnalise){
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ReportNaoEncontrado("Report Não Encontrado"));
        SupervisorDeUnidade supervisor = supervisorRepository.findById(reportStatusAnalise.SupervisorId())
                        .orElseThrow(() -> new SupervisorNaoEncontrado("Supervisor Não Encontrado"));
        report.setStatus(StatusReport.StringParaTipo(reportStatusAnalise.Status()));
        report.setDataDaAnalisa(LocalDateTime.now());
        report.setSupervisor(supervisor);
        reportRepository.save(report);

        return new ReportExpandidoDTO(report);
    }
    private Report CriarReport(ReportCreateDTO reportDTO,LocalizacaoDTO localizaoDTO, Long unidadeId){
        Report report = new Report();
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

        if (localizaoDTO != null){
            report.setLongitude(localizaoDTO.Longitude());
            report.setLatitude(localizaoDTO.Latitude());
            report.setImagemOrigem(ImagemOrigem.GPS_CELULAR);
        }

        return report;
    }
}
