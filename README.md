# Safe Driver 🚗✨

![Logo do Safe Driver](./safe_driver/assets/images/logo.png)

*Um aplicativo mobile desenvolvido em Flutter para monitoramento de direção, gamificação de boas práticas no trânsito e histórico de desempenho do motorista.*

---

## 📜 Sobre o Projeto

O **Safe Driver** é um aplicativo mobile focado em promover uma direção mais segura e econômica. Através de um sistema de monitoramento em tempo real, o app coleta dados de condução e os utiliza para gerar pontuações, desafios e um histórico detalhado de desempenho. A ideia é usar a gamificação para incentivar os motoristas a adotarem melhores práticas no trânsito, oferecendo recompensas (pontos) e um ranking competitivo.

Este projeto foi construído inteiramente com Flutter, garantindo uma experiência de usuário fluida e um código-base único para múltiplas plataformas.

## 🚀 Funcionalidades Principais

-   **Autenticação de Usuários:** Fluxo completo com telas de Login, Cadastro, Recuperação de Senha e Logout seguro.
-   **Perfil de Usuário:** Tela de perfil completa e editável, com suporte a foto, dados pessoais e informações do veículo.
-   **Tela Inicial Dinâmica:** Dashboard principal com um carrossel de status (plano do dia, ranking) e atalhos para as principais funcionalidades.
-   **Mapa com Localização Atual:** Integração com `geolocator` e `flutter_map` para exibir a posição do usuário em tempo real.
-   **Histórico de Desempenho:** Tela com gráficos dinâmicos e animados (`fl_chart`) que exibem a performance do motorista em diferentes períodos (diário, semanal, mensal, anual).
-   **Lista de Corridas:** Histórico detalhado de todas as corridas realizadas, com informações de distância, economia e pontuação.
-   **Sistema de Filtros:** Filtro funcional por período de datas na tela de corridas.
-   **Tela de Ranking:** Exibe a pontuação total do usuário e uma lista de desafios disponíveis para resgate de pontos.
-   **Monitoramento de Viagem:** Tela de simulação de monitoramento em tempo real com feedback de eventos, como "frenagem brusca".

## 🛠️ Tech Stack e Principais Pacotes

-   **Framework:** Flutter
-   **Linguagem:** Dart
-   **Backend (BaaS):** Supabase (planejado)
-   **Principais Pacotes:**
    -   `flutter_map` e `latlong2`: Para exibição de mapas.
    -   `geolocator`: Para obter a localização GPS do dispositivo.
    -   `fl_chart`: Para a criação de gráficos dinâmicos e animados.
    -   `image_picker`: Para seleção de fotos da galeria ou câmera.
    -   `intl`: Para formatação de datas e internacionalização.

## 🚀 Como Executar o Projeto

**Pré-requisitos:**
-   Ter o [SDK do Flutter](https://flutter.dev/docs/get-started/install) instalado.
-   Um emulador Android/iOS ou um dispositivo físico conectado.

**Passos:**

1.  Clone o repositório:
    ```sh
    git clone https://github.com/Fioshi/safe-driver.git
    ```

2.  Navegue até a pasta do projeto:
    ```sh
    cd safe-driver
    ```

3.  Instale as dependências:
    ```sh
    flutter pub get
    ```

4.  Execute o aplicativo:
    ```sh
    flutter run
    ```

---

## 📄 Licença

Este projeto está sob a licença MIT.

## 👨‍💻 Autor

Desenvolvidos pelo time **Safe-Driver**.
