export const verifyEmailPage = (
  token: string,
  url: string,
): string => `<!doctype html>
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
                  Obrigado por se registar! Para começar a usar a plataforma,
                  por favor valide o seu endereço de email clicando no botão
                  abaixo.
                </p>

                <table
                  role="presentation"
                  border="0"
                  cellspacing="0"
                  cellpadding="0"
                  style="margin: 0 auto"
                >
                  <tr>
                    <td
                      align="center"
                      style="border-radius: 4px"
                      bgcolor="#004d99"
                    >
                      <a
                        href="http://localhost:10000/api/auth/verify-email?token=${token}&callbackURL=${url}"
                        target="_blank"
                        style="
                          font-size: 16px;
                          font-family: sans-serif;
                          font-weight: bold;
                          color: #ffffff;
                          text-decoration: none;
                          padding: 12px 24px;
                          border-radius: 4px;
                          border: 1px solid #004d99;
                          display: inline-block;
                        "
                      >
                        Verificar Email
                      </a>
                    </td>
                  </tr>
                </table>

                <div
                  style="
                    margin-top: 40px;
                    border-top: 1px solid #eeeeee;
                    padding-top: 20px;
                  "
                >
                  <p
                    style="color: #999999; font-size: 14px; margin-bottom: 10px"
                  >
                    Ou utilize o código manualmente:
                  </p>
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
                      >${token}</strong
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
                  Se não criou esta conta, pode ignorar este email com
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
