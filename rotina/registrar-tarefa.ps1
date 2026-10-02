# Registra (ou recria) a tarefa agendada do Windows que roda a rotina todo dia as 18:00.
# Para remover: Unregister-ScheduledTask -TaskName 'Atualizar relatorio de trabalho' -Confirm:$false
$nome   = 'Atualizar relatorio de trabalho'
$script = Join-Path $PSScriptRoot 'atualizar-relatorio.ps1'

$acao    = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
$gatilho = New-ScheduledTaskTrigger -Daily -At '18:00'
$config  = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask -TaskName $nome -Action $acao -Trigger $gatilho -Settings $config -Force `
    -Description 'Atualiza o index.html do relatorio de trabalho com o Claude e faz commit + push.'
