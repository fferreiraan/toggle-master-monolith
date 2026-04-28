# Tech Challenge - Arquitetura Monolítica na AWS

## Arquitetura da Solução

[Arquitetura](./docs/arquitetura.png)

> A imagem representa a separação entre camada de aplicação e banco de dados dentro de uma VPC, utilizando boas práticas básicas de segurança.

---

## Descrição da Arquitetura

A arquitetura foi construída na AWS utilizando uma abordagem simples, adequada para um cenário de MVP.

### Componentes:

- **VPC**: isolamento da rede
- **Sub-rede pública**:
  - EC2 responsável pela aplicação
- **Sub-rede privada**:
  - RDS PostgreSQL
- **Security Groups**:
  - EC2:
    - HTTP (80) → Internet
    - HTTPS (443) → Internet
    - SSH (22) → IP restrito
  - RDS:
    - PostgreSQL (5432) → apenas EC2

### Fluxo:

---

## Infraestrutura implementada

### EC2

- Tipo: t2.micro
- Sistema: Amazon Linux 2023
- Responsável por:
  - Rodar a API Flask via Gunicorn
  - Executar Nginx como proxy reverso

---

### RDS

- Engine: PostgreSQL
- Tipo: db.t3.micro
- Armazenamento: 20GB
- Sem acesso público
- Acesso restrito via Security Group

---

### Nginx

Foi utilizado como **proxy reverso**, expondo a aplicação na porta 80.

Função:
- Receber requisições externas
- Redirecionar internamente para a aplicação na porta 5000

---

## Processo de Deploy

O deploy foi automatizado via script `setup.sh`, que executa:

1. Limpeza do diretório da aplicação
2. Instalação de dependências (Python, pip, dos2unix, nginx)
3. Cópia dos arquivos da aplicação
4. Conversão de arquivos para padrão Unix (LF)
5. Criação de ambiente virtual (venv)
6. Instalação de dependências via `requirements.txt`
7. Carregamento de variáveis de ambiente (`.env`)
8. Inicialização do banco de dados (`flask init-db`)
9. Configuração do Nginx
10. Configuração do serviço systemd
11. Start da aplicação

---

## Análise da aplicação como monólito

A aplicação analisada é considerada um monólito porque toda a lógica do sistema está concentrada em um único projeto. Isso significa que funcionalidades como regras de negócio, acesso ao banco de dados e endpoints da API estão no mesmo código e são executadas em um único processo.

Não existe separação entre serviços independentes, como ocorreria em uma 

---

## Vantagens e desvantagens para um MVP

### Vantagens

- Simplicidade de desenvolvimento
- Deploy mais rápido
- Menor custo inicial
- Facilidade de entendimento

### Desvantagens

- Escalabilidade limitada
- Alto acoplamento
- Manutenção mais complexa com crescimento
- Risco maior de impacto em mudanças


---

## Análise baseada nos 12-Factor App

### Pontos atendidos

- Código versionado (Git)
- Dependências declaradas (`requirements.txt`)
- Uso de variáveis de ambiente (parcial)

### Pontos de melhoria

- Configuração ainda parcialmente acoplada
- Logs não estruturados
- Falta separação clara entre build/release/run
- Escalabilidade limitada por ser monolito


---

## Estimativa de custo

Estimativa realizada com AWS Pricing Calculator:

https://calculator.aws/#/estimate?nc2=h_pr_calc

### Recursos considerados:

- EC2 t2.micro
- RDS db.t3.micro
- 20GB armazenamento
- Modelo On-Demand

### Custo estimado:

**~23,91 USD/mês**

Esse valor é adequado para um ambiente de MVP, mantendo baixo custo e simplicidade.


---

## Boas práticas aplicadas

- Banco em subnet privada (não exposto)
- Security Group restritivo (RDS só aceita EC2)
- SSH limitado por IP
- Uso de proxy reverso (Nginx)
- Variáveis de ambiente para configuração
- Automação de deploy via script

---

## Conclusão

A solução atende bem ao objetivo de um MVP:

- Simples
- Funcional
- Baixo custo
- Segura dentro do contexto proposto

Para evolução futura:

- Implementar HTTPS (SSL)
- Melhorar observabilidade (logs estruturados)
- Separar camadas (possível migração para microsserviços)
- Pipeline de CI/CD

