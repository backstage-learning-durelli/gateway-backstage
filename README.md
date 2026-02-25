# gateway-backstage

Spring Boot Cloud Gateway criado via Backstage.

[![CI/CD Pipeline](https://github.com/backstage-learning-durelli/gateway-backstage/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/backstage-learning-durelli/gateway-backstage/actions/workflows/ci-cd.yaml)

## 🚀 Tecnologias

- **Java 17**
- **Spring Boot 3.4.2**
- **Spring Cloud Gateway 2024.0.1**
- **Maven 3.9+**
- **Docker** (multi-platform: amd64/arm64)
- **Kubernetes**
- **ArgoCD**

## 📋 Pré-requisitos

- JDK 17+
- Maven 3.9+ (ou use o wrapper: `./mvnw`)
- Docker
- kubectl (para deploy local)

## 🏁 Getting Started

### Desenvolvimento Local

```bash
# Clone o repositório
git clone https://github.com/backstage-learning-durelli/gateway-backstage.git
cd gateway-backstage

# Compile e rode os testes
./mvnw clean test

# Execute a aplicação
./mvnw spring-boot:run

# Aplicação disponível em: http://localhost:8080
```

## 🛣️ Rotas Configuradas

A aplicação possui as seguintes rotas de exemplo:

### Health Check
- **Endpoint**: `/actuator/health`
- **Método**: GET
- **Exemplo**:
  ```bash
  curl http://localhost:8080/actuator/health
  ```

### Liveness Probe
- **Endpoint**: `/actuator/health/liveness`
- **Método**: GET

### Readiness Probe
- **Endpoint**: `/actuator/health/readiness`
- **Método**: GET

### Rota de Exemplo (JSONPlaceholder)
- **Endpoint**: `/api/v1/data`
- **Upstream**: https://jsonplaceholder.typicode.com/posts
- **Método**: GET
- **Exemplo**:
  ```bash
  curl http://localhost:8080/api/v1/data
  ```

## 🧪 Testes

```bash
# Rodar todos os testes
./mvnw test

# Rodar com cobertura (requer plugin jacoco no pom.xml)
./mvnw test jacoco:report
```

## 🐳 Docker

### Build Local
```bash
docker build -t gateway-backstage:latest .
```

### Run Container
```bash
docker run -p 8080:8080 gateway-backstage:latest
```

### Docker Hub
As imagens são publicadas automaticamente via CI/CD:
- `durellirsd/gateway-backstage:latest` - Última versão da branch main
- `durellirsd/gateway-backstage:main-<short-sha>` - Versão específica por commit

## 🔄 CI/CD e Deployment

### Pipeline Automático

O projeto usa GitHub Actions para CI/CD:

1. **Test**: Executa testes unitários com Maven
2. **Build**: Compila aplicação e cria imagem Docker
3. **Push**: Publica imagem multi-plataforma (linux/amd64, linux/arm64) no Docker Hub
4. **Update**: Atualiza manifests Kubernetes automaticamente com nova tag

### ArgoCD Deployment

O deployment é gerenciado pelo ArgoCD:

- **Application**: `gateway-backstage`
- **Namespace**: `gateway-backstage`
- **Sync Policy**: Automático (prune + self-heal)
- **Repository**: https://github.com/backstage-learning-durelli/gateway-backstage
- **Path**: `k8s/`

## ☸️ Kubernetes

### Recursos Criados

- **Deployment**: 2 réplicas com health checks (liveness/readiness)
- **Service**: ClusterIP na porta 80 → 8080
- **Ingress**: Expõe aplicação via NGINX
- **Namespace**: `gateway-backstage`

### Recursos do Gateway

O Gateway possui recursos aumentados devido ao proxying:

```yaml
resources:
  requests:
    memory: "384Mi"
    cpu: "300m"
  limits:
    memory: "768Mi"
    cpu: "600m"
```

### Verificar Deployment

```bash
# Ver todos os recursos
kubectl get all -n gateway-backstage

# Ver logs
kubectl logs -f deployment/gateway-backstage -n gateway-backstage

# Port-forward para teste local
kubectl port-forward -n gateway-backstage svc/gateway-backstage 8080:80

# Testar via port-forward
curl http://localhost:8080/actuator/health
curl http://localhost:8080/api/v1/data
```

## ⚙️ Configuração de Rotas

As rotas são configuradas em `src/main/resources/application.yml`:

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: example-route
          uri: https://api.example.com
          predicates:
            - Path=/api/**
          filters:
            - StripPrefix=1
```

### Adicionar Nova Rota

1. Edite `src/main/resources/application.yml`
2. Adicione novo item em `spring.cloud.gateway.routes`
3. Configure:
   - **id**: Identificador único da rota
   - **uri**: URL do serviço de destino
   - **predicates**: Condições para matching (Path, Method, Header, etc.)
   - **filters**: Transformações na requisição/resposta
4. Commit e push (CI/CD atualiza automaticamente)

### Filtros Disponíveis

Alguns filtros úteis do Spring Cloud Gateway:

- `SetPath`: Reescreve o path da requisição
- `StripPrefix`: Remove prefixos do path
- `AddRequestHeader`: Adiciona headers na requisição
- `AddResponseHeader`: Adiciona headers na resposta
- `RewritePath`: Usa regex para reescrever paths
- `Retry`: Configura retry automático

Documentação completa: https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#gatewayfilter-factories

## 📁 Estrutura do Projeto

```
gateway-backstage/
├── .github/
│   └── workflows/
│       └── ci-cd.yaml          # Pipeline CI/CD
├── k8s/                         # Manifests Kubernetes
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/gateway/
│   │   │       └── GatewayApplication.java
│   │   └── resources/
│   │       └── application.yml  # Configuração de rotas
│   └── test/
│       └── java/
│           └── com/example/gateway/
│               └── GatewayApplicationTests.java
├── Dockerfile
├── pom.xml
├── catalog-info.yaml           # Backstage catalog
└── README.md
```

## 🔐 Secrets e Configuração

### GitHub Secrets Necessários

Configure os seguintes secrets no repositório GitHub:

- `DOCKERHUB_USERNAME`: Username do Docker Hub
- `DOCKERHUB_TOKEN`: Token de acesso do Docker Hub

### Variáveis de Ambiente (Produção)

Configuradas via Kubernetes Deployment:

- `SPRING_PROFILES_ACTIVE=production`

### Configuração de Logging

O nível de log do gateway está em DEBUG para facilitar troubleshooting:

```yaml
logging:
  level:
    org.springframework.cloud.gateway: DEBUG
```

Ajuste conforme necessário para produção.

## 🔍 Observabilidade

### Endpoints Actuator

O Spring Boot Actuator expõe endpoints úteis para monitoramento:

- `/actuator/health` - Status geral da aplicação
- `/actuator/health/liveness` - Liveness probe para K8s
- `/actuator/health/readiness` - Readiness probe para K8s
- `/actuator/info` - Informações da aplicação
- `/actuator/metrics` - Métricas da aplicação
- `/actuator/prometheus` - Métricas no formato Prometheus

### Métricas

Integre com Prometheus/Grafana para visualização de métricas:

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'gateway-backstage'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - gateway-backstage
    metrics_path: '/actuator/prometheus'
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-rota`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova rota para serviço X'`)
4. Push para a branch (`git push origin feature/nova-rota`)
5. Abra um Pull Request

### Convenção de Commits

Seguimos a convenção [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `chore:` Tarefas de manutenção
- `refactor:` Refatoração de código

## 📚 Recursos Úteis

- [Spring Cloud Gateway Docs](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Backstage Documentation](https://backstage.io/docs/overview/what-is-backstage)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

---

🤖 Projeto criado via [Backstage](https://backstage.io) | 🚀 Powered by Spring Cloud Gateway
