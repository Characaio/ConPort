package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.AvisoCreateDTO;
import com.example.ecoportapi.Services.AvisoService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/avisos")
public class AvisoController {

    private final AvisoService avisoService;

    public AvisoController(AvisoService avisoService) {
        this.avisoService = avisoService;
    }

    @GetMapping("/{unidadeId}/Aviso")
    public ResponseEntity<?> BuscarAvisos(
            @RequestParam(defaultValue = "1") Integer limite,
            @PathVariable Long unidadeId
    ){
        /*
        Essa função usa um sistema de pageabl
        Para pegar o aviso mais recente, coloque o limit como 1
        Para pegar uma lista de avisos coloque um limite alto
        */

        //MAIS TARDE MUDAR ESSA LOGICA PARA PAGEABLE
        return ResponseEntity.ok(avisoService.BuscarAvisos(unidadeId,limite));
    }

    @PostMapping("/{unidadeId}/Aviso")
    public ResponseEntity<?> PostarAviso(
            @RequestBody AvisoCreateDTO avisoDTO,
            @PathVariable Long unidadeId
    ){

        return ResponseEntity.ok(avisoService.PostarAviso(avisoDTO,unidadeId));
    }
}
