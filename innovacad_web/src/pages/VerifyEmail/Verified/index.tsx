import { useUserDetails } from "@/providers/UserDetailsProvider";
import { useNavigate, useSearchParams } from "@solidjs/router";

const VerifiedEmail = () => {
  const navigate = useNavigate();
  const { user } = useUserDetails();
  const [searchParams, setSearchParams] = useSearchParams();

  if (!!user() || !user()?.verified) {
    navigate("/verify-email");
  }

  return <h1>Verified email!</h1>;
};

export default VerifiedEmail;
