# mri_Qjobsystem_v2 (Qbox + ox stack)

Sistema de criação/gestão de jobs e gangs focado em Qbox e ecossistema ox.

## Dependências
- qbx_core
- qbx_management
- ox_lib
- ox_inventory
- ox_target
- oxmysql
- mri_Qbox

## Estrutura (padronizada no estilo pls_jobsystem)
```txt
fxmanifest.lua
shared/
  bridge.lua
  config.lua
  secure.lua
  utilities.lua
client/
  main.lua
  creator.lua
  bridge/
    inventory.lua
    target.lua
server/
  main.lua
  db.lua
  bridge/
    framework.lua
    inventory.lua
  data/
    jobs.json
    backup.json
locales/
```

## Comandos
- `/createjob` - abre o criador de jobs/gangs
- `/open_jobs` - abre o menu administrativo

## Configuração principal
Arquivo: `shared/config.lua`

```lua
Config.Security = {
    maxCraftAmount = 50,
    creatorAce = 'group.admin'
}
```

## Notas
- A base foi reorganizada para um padrão semântico-funcional próximo ao `pls_jobsystem`.
- Fluxos legados multi-framework foram removidos para manter foco em Qbox/ox.
