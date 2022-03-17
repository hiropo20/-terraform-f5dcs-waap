F5 DCS WAAP を Terraform で操作する方法
####

F5 DCS WAAP を設定する方法
====

F5 DCS WAAP は以下の方法で設定することが可能です

- ダッシュボードからGUIで操作し、オブジェクトの作成
- Terraform Provider を利用したオブジェクトの作成
- API を利用したオブジェクトの作成

F5 DCS WAAP に関連する Terraform の情報について
====

この章では、F5 DCS WAAP に関連するTerraformの情報を紹介します

Terraform ドキュメント
----

F5 DCS WAAP の Terraform は以下ドキュメントで紹介されています

- `Terraform F5 DCS <https://registry.terraform.io/namespaces/volterraedge>`__ 

画面右上の ``Documentation`` を開いてください

   .. image:: ./media/terraform-volterra.jpg
       :width: 400

利用の開始は記事中の内容に従って操作してください。
また、画面左側から Provider が提供する各種機能を参照できます

   .. image:: ./media/terraform-volterra2.jpg
       :width: 400

F5 DCS WAAP で Terraform を利用する方法
====

F5 DCS WAAP Terraform Provider
----

Provider を利用する際、に以下を記述します

.. code-block:: bash
  :linenos:
  :caption: F5 DCS Provider を利用する方法

  provider "volterra" {
    api_p12_file     = "/path/to/api_credential.p12"
    url              = "https://<tenant_name>.console.ves.volterra.io/api"
  }

以下パラメータを指定します。

============= ==== ==================================================
api_p12_file  `-`  APIの認証情報として用いる、P12のファイルのPath情報
url           必須 F5 DCS の API Endopoint を示すURL
============= ==== ==================================================

その他詳細についてはマニュアルの内容を参照してください。

Terraform で利用する API 証明書の取得
----

Terraformを実行するホストでAPIに接続するための証明書が必要となります。証明書の作成方法を示します。
マニュアルは以下のページを参照してください。

- `Credentials <https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials>`__

F5 DCS のコンソールを開き、 ``Administration`` を開きます

   .. image:: ./media/dcs-console-administration.jpg
       :width: 400

Personal Management の ``Credentials`` を開き、上部に表示される ``Create Credentials`` をクリックします

   .. image:: ./media/dcs-create-credentials.jpg
       :width: 400

画面左側に表示される項目に各種情報を入力してください。 ``Credential Type`` は ``API Certificate`` を指定ください。パスワードは、Terraform を利用するホストの環境変数 ``VES_P12_PASSWORD`` に指定しますのでメモしてください。
他のパラメータは環境に合わせて自由に指定してください。

   .. image:: ./media/dcs-create-credentials2.jpg
       :width: 400

入力後、画面最下部の ``Download`` をクリックします。ポップアップでファイルのダウンロードを求められますので適当な場所に APIに用いる証明書を保存してください

こちらの証明書を利用する際、Terraformは環境変数の ``VES_P12_PASSWORD`` の値が、作成した証明書の値と一致する必要があります。実行する環境に合わせて環境変数を設定してください。以下はUbuntuの環境でbashの環境変数として指定する例です

.. code-block:: bash
  :linenos:
  :caption: 環境変数の指定

  $ export VES_P12_PASSWORD=**password-string**

必要なパッケージの確認
----

F5 DCS が提供するため Terraform と Go言語 のパッケージが必要となります。 
本書作成時点のの対応バージョンは以下となります。

- Terraform >= 0.13.x

情報は以下を参照してください。
Provider は Terraform 実行時、自動的に取得しますのでこちらのページのBuildは不要です

- `Git terraform-provider-volterra <https://github.com/volterraedge/terraform-provider-volterra>`__

Terraformのインストール手順は以下を参照してください。

- `Download Terraform <https://www.terraform.io/downloads>`__

Terraform の動作確認
----

正しく動作することを確認します。
必要となるファイルを取得してください。

.. code-block:: bash
  :linenos:
  :caption: terraform initの実行結果
  :emphasize-lines: 5-7

  $ git clone https://github.com/hiropo20/terraform-f5dcs-waap.git
  $ cd connection-test

以下、 ``test.tf`` の内容を環境に合わせて修正してください。

.. code-block:: bash
  :linenos:
  :caption: terraform initの実行結果
  :emphasize-lines: 13,14,20

  $ vi test.tf
  
  terraform {
    required_providers {
      volterra = {
        source  = "volterraedge/volterra"
        version = "0.11.6"
      }
    }
  }
  
  provider "volterra" {
    api_p12_file = "**/path/to/api_credential.p12-file**"
    url          = "https://**tenant_name**.console.ves.volterra.io/api"
  }
  
  // example: create healthcheck object
  resource "volterra_healthcheck" "eample-dummy-hc" {
    name                = "dummy-health-check-t"
    namespace           = "**your-namespace**"
    timeout             = 3
    interval            = 15
    unhealthy_threshold = 1
    healthy_threshold   = 3
    http_health_check {
      use_origin_server_name = true
      path                   = "/"
      use_http2              = false
    }
  }


Terraform の動作確認
----

terraform init を実行します。初回実行時、5-7行目に示す通り、Providerが取得されます

.. code-block:: bash
  :linenos:
  :caption: terraform initの実行結果
  :emphasize-lines: 5-7

  $ terraform init
  
  Initializing the backend...
  
  Initializing provider plugins...
  - Finding volterraedge/volterra versions matching "0.11.6"...
  - Installing volterraedge/volterra v0.11.6...
  - Installed volterraedge/volterra v0.11.6 (signed by a HashiCorp partner, key ID D9A99FF2F2E29E35)
  
  Partner and community providers are signed by their developers.
  If you'd like to know more about provider signing, you can read about it here:
  https://www.terraform.io/docs/cli/plugins/signing.html
  
  Terraform has created a lock file .terraform.lock.hcl to record the provider
  selections it made above. Include this file in your version control repository
  so that Terraform can guarantee to make the same selections by default when
  you run "terraform init" in the future.
  
  Terraform has been successfully initialized!
  
  You may now begin working with Terraform. Try running "terraform plan" to see
  any changes that are required for your infrastructure. All Terraform commands
  should now work.
  
  If you ever set or change modules or backend configuration for Terraform,
  rerun this command to reinitialize your working directory. If you forget, other
  commands will detect it and remind you to do so if necessary.


terraform plan を実行します

.. code-block:: bash
  :linenos:
  :caption: terraform planの実行結果
  :emphasize-lines: 8

  $ terraform plan
  
  Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
  symbols:
    + create
  
  Terraform will perform the following actions:
  
    # volterra_healthcheck.eample-dummy-hc will be created
    + resource "volterra_healthcheck" "eample-dummy-hc" {
        + healthy_threshold   = 3
        + id                  = (known after apply)
        + interval            = 15
        + name                = "dummy-health-check-t"
        + namespace           = "**your-namespace**"
        + timeout             = 3
        + unhealthy_threshold = 1
  
        + http_health_check {
            + path                      = "/"
            + request_headers_to_remove = []
            + use_http2                 = false
            + use_origin_server_name    = true
          }
      }
  
  Plan: 1 to add, 0 to change, 0 to destroy.
  
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  
  Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform
  apply" now.

terraform apply を実行し、設定を反映します。

.. code-block:: bash
  :linenos:
  :caption: terraform planの実行結果
  :emphasize-lines: 33

  $ terraform apply
  
  Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
  symbols:
    + create
  
  Terraform will perform the following actions:
  
    # volterra_healthcheck.eample-dummy-hc will be created
    + resource "volterra_healthcheck" "eample-dummy-hc" {
        + healthy_threshold   = 3
        + id                  = (known after apply)
        + interval            = 15
        + name                = "dummy-health-check-t"
        + namespace           = "**your-namespace**"
        + timeout             = 3
        + unhealthy_threshold = 1
  
        + http_health_check {
            + path                      = "/"
            + request_headers_to_remove = []
            + use_http2                 = false
            + use_origin_server_name    = true
          }
      }
  
  Plan: 1 to add, 0 to change, 0 to destroy.
  
  Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.
  
    Enter a value: yes   <<< yes と入力する
  
  volterra_healthcheck.eample-dummy-hc: Creating...
  volterra_healthcheck.eample-dummy-hc: Creation complete after 1s [id=******]
  
  Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Applyが完了しました。コンソールを開き、正しくオブジェクトが作成されたことを確認します

   .. image:: ./media/dcs-terraform-apply-dummy.jpg
       :width: 400

terraform destroy を実行し、設定を削除します


.. code-block:: bash
  :linenos:
  :caption: terraform destroyの実行結果
  :emphasize-lines: 38

  $ terraform destroy
  volterra_healthcheck.eample-dummy-hc: Refreshing state... [id=******]
  
  Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
  symbols:
    - destroy
  
  Terraform will perform the following actions:
  
    # volterra_healthcheck.eample-dummy-hc will be destroyed
    - resource "volterra_healthcheck" "eample-dummy-hc" {
        - annotations         = {} -> null
        - disable             = false -> null
        - healthy_threshold   = 3 -> null
        - id                  = "******" -> null
        - interval            = 15 -> null
        - labels              = {} -> null
        - name                = "dummy-health-check-t" -> null
        - namespace           = "**your-namespace**" -> null
        - timeout             = 3 -> null
        - unhealthy_threshold = 1 -> null
  
        - http_health_check {
            - headers                   = {} -> null
            - path                      = "/" -> null
            - request_headers_to_remove = [] -> null
            - use_http2                 = false -> null
            - use_origin_server_name    = true -> null
          }
      }
  
  Plan: 0 to add, 0 to change, 1 to destroy.
  
  Do you really want to destroy all resources?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.
  
    Enter a value: yes   <<< yes と入力する
  
  volterra_healthcheck.eample-dummy-hc: Destroying... [id=******]
  volterra_healthcheck.eample-dummy-hc: Destruction complete after 1s
  
  Destroy complete! Resources: 1 destroyed.
  ubuntu@ip-10-0-11-227:~/temp2$ cat test.tf
  terraform {
    required_providers {
      volterra = {
        source  = "volterraedge/volterra"
        version = "0.11.6"
      }
    }
  }
  
  provider "volterra" {
    api_p12_file = "/home/ubuntu/f5-apac-ent.console.ves.volterra.io.api-creds.p12"
    url          = "https://f5-apac-ent.console.ves.volterra.io/api"
  }
  
  // example: create healthcheck object
  resource "volterra_healthcheck" "eample-dummy-hc" {
    name                = "dummy-health-check-t"
    namespace           = "h-matsumoto"
    timeout             = 3
    interval            = 15
    unhealthy_threshold = 1
    healthy_threshold   = 3
    http_health_check {
      use_origin_server_name = true
      path                   = "/"
      use_http2              = false
    }
  }


削除の結果を確認します。

   .. image:: ./media/dcs-terraform-destroy-dummy.jpg
       :width: 400


Terraformを使って正しく、追加、削除が出来ることが確認できました

