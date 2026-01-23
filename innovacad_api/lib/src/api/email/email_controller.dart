import 'package:dotenv/dotenv.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:vaden/vaden.dart';

@DTO()
class SendEmailDto {
  final String to;
  final String subject;
  final String body;

  SendEmailDto(this.to, this.subject, this.body);
}

@Api(tag: "Email")
@Controller("/email")
class EmailController {
  @Post("/send")
  Future<Response> sendEmail(@Body() SendEmailDto dto) async {
    try {
      var env = DotEnv(includePlatformEnvironment: true)..load();
      final smtpServer = gmail(
        'peterdroidyt@gmail.com',
        env['GOOGLE_GMAIL_SECRET'] ?? "google_gmail_secret",
      );
      final message = Message()
        ..from = Address('admin@yourcompany.com', 'Admin System')
        ..recipients.add(dto.to)
        ..subject = dto.subject
        ..html = dto.body;

      await send(message, smtpServer);

      return resultToResponse(Result.success("Email sent successfully!"));
    } on MailerException catch (e, s) {
      return resultToResponse(
        Result.failure(
          AppError(
            AppErrorType.internal,
            "Couldn't send email: ${e.toString()}",
            details: {"stack": s.toString()},
          ),
        ),
      );
    }
  }
}
