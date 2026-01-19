export const twoFactorPage = (otp: string): string => `<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Verifique o seu Email</title>
    <style>
      /* Reset básico para garantir que fica igual em todo o lado */
      body {
        margin: 0;
        padding: 0;
        font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        background-color: #f4f4f4;
      }
      table {
        border-collapse: collapse;
      }

      /* Estilos responsivos para telemóvel */
      @media screen and (max-width: 600px) {
        .container {
          width: 100% !important;
        }
        .content {
          padding: 20px !important;
        }
      }
    </style>
  </head>
  <body style="margin: 0; padding: 0; background-color: #f4f4f4">
    <table
      role="presentation"
      width="100%"
      border="0"
      cellspacing="0"
      cellpadding="0"
    >
      <tr>
        <td align="center" style="padding: 40px 0">
          <table
            class="container"
            role="presentation"
            width="600"
            border="0"
            cellspacing="0"
            cellpadding="0"
            style="
              background-color: #ffffff;
              border-radius: 8px;
              box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
              overflow: hidden;
            "
          >
            <tr>
              <td
                style="
                  background-color: #004d99;
                  padding: 30px;
                  text-align: center;
                "
              >
                <h1
                  style="
                    color: #ffffff;
                    margin: 0;
                    font-size: 24px;
                    letter-spacing: 1px;
                  "
                >
                  INNOVACAD
                </h1>
              </td>
            </tr>

            <tr>
              <td
                class="content"
                style="padding: 40px 30px; text-align: center"
              >
                <h2 style="color: #333333; margin-top: 0; font-size: 22px">
                  Verifique a sua conta
                </h2>
                <p
                  style="
                    color: #666666;
                    font-size: 16px;
                    line-height: 1.5;
                    margin-bottom: 30px;
                  "
                >
                  Obrigado por utilizar a Innovacad! Para começar a usar a
                  plataforma, por favor valide o seu endereço de email inserindo
                  o código abaixo na aplicação.
                </p>

                <div style="margin-top: 40px; padding-top: 20px">
                  <div
                    style="
                      background-color: #f8f9fa;
                      padding: 15px;
                      border-radius: 4px;
                      border: 1px dashed #cccccc;
                      display: inline-block;
                    "
                  >
                    <strong
                      style="
                        font-size: 20px;
                        color: #333333;
                        letter-spacing: 2px;
                      "
                      >${otp}</strong
                    >
                  </div>
                </div>
              </td>
            </tr>

            <tr>
              <td
                style="
                  background-color: #eeeeee;
                  padding: 20px;
                  text-align: center;
                "
              >
                <p style="color: #999999; font-size: 12px; margin: 0">
                  Se não conhece esta conta, pode ignorar este email com
                  segurança.<br />
                  &copy; 2026 Innovacad - Projeto ATEC
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>`;
