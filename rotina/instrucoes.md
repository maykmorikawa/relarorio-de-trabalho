# Atualização diária do relatório

Você está rodando sem supervisão, numa tarefa agendada. Atualize o `index.html` (Relatório de Atividades do Mayk Morikawa) com a atividade descrita em `rotina/atividade-do-dia.md`. Esse arquivo lista, por projeto de `C:\xampp\htdocs`, os commits do Mayk e os arquivos alterados desde a última execução.

## O que fazer

1. Leia `rotina/atividade-do-dia.md` e o `index.html` inteiro.
2. Se precisar entender um projeto, leia o README ou os arquivos alterados nele (só leitura).
3. Edite **apenas** o `index.html`:
   - **Emitido em:** troque pela data de hoje (está no topo de `atividade-do-dia.md`). Se o mês de hoje passar do fim do **Período**, estenda o período.
   - **Atividades:** incorpore o que foi feito no card do projeto correspondente, como um item novo ou complementando um item existente. Se o projeto ainda não aparece no relatório, crie um card na seção mais adequada. Escreva no mesmo tom do relatório: frases curtas, em português, voltadas para um gestor e sem jargão desnecessário.
   - **Tabela "Atualizações versionadas por mês":** some o "Total de commits novos" à linha do mês atual e atualize o "(até dia N)". Se o mês ainda não tiver linha, crie uma. Recalcule a linha **Total**, ajuste a coluna "Principais frentes" se for o caso e mantenha o KPI de commits igual ao total da tabela.
   - **KPIs:** atualize "projetos e sites trabalhados", "landing pages" ou "novos módulos" só quando a atividade de fato justificar.

## Regras

- Não invente nada. Descreva somente o que os commits e arquivos indicam. Se houver só nomes de arquivos, descreva de forma genérica (por exemplo: "ajustes de layout na página X").
- Ignore alterações triviais ou automáticas, como logs, caches, uploads de imagens soltas e arquivos de configuração local.
- Não remova nem reescreva o conteúdo existente além do necessário. Não mude o CSS nem a estrutura.
- Se nada for relevante, atualize só a data de emissão.
- Não rode comandos e não faça commits. O script cuida do Git.
