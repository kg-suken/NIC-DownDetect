# NIC監視&再起動スクリプト

intelのデバイスがハングアップする問題があったので作成ました。
このスクリプトを使用するよりtsoを無効化したほうがよいです
NIC再起動時はDiscordのWebHookに通知します

ネットワークデバイスを確認し、デバイスの再起動を試みます。
**三回ネットワークデバイスの再起動に失敗した場合はPCを再起動します**

定常的に動かす場合はcrontabなどをご利用ください。