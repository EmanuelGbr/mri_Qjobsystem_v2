# mri_Qjobsystem_v2 (Qbox + ox stack)

Sistema de criação/gestão de jobs e gangs com foco em **Qbox**, **ox_lib**, **ox_inventory**, **ox_target** e **oxmysql**.

## Dependências
- qbx_core
- qbx_management
- ox_lib
- ox_inventory
- ox_target
- oxmysql
- mri_Qbox

## Comandos
- `/createjob` - abre o criador de jobs/gangs
- `/open_jobs` - abre o menu administrativo

## Principais mudanças desta versão
- Bridge simplificada para stack nativo Qbox/ox (removidas camadas multi-framework legadas).
- Registro de stashes e shops nativamente via ox_inventory.
- Interações unificadas em ox_target.
- Suporte a peds configurados em `job.peds` (model + cenário/animação), com spawn/cleanup automáticos.
- Validações no servidor para crafting, permissões administrativas e acesso por job/gang.
- Configuração de segurança centralizada em `config.lua`.

## Configuração
### Segurança
```lua
Config.Security = {
    maxCraftAmount = 50,
    creatorAce = 'group.admin'
}
```

### Diretório de imagens
```lua
Config.DirectoryToInventoryImages = 'nui://ox_inventory/web/images/'
```

## Observações
- O recurso agora é intencionalmente focado em Qbox + ox stack.
- Para abrir menus de gestão, o player deve possuir ACE do `Config.Security.creatorAce`.
