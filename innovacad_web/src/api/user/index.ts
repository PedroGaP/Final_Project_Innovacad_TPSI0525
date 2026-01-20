import { Trainee, Trainer, type UserResponseData } from "@/types/user";
import { fetchApi } from "@/api/api";
import toast from "solid-toast";

export const USER_ENDPOINTS = {
  TRAINEES: "/trainees",
  TRAINERS: "/trainers",
} as const;

export const useUserApi = () => {

  const fetchTrainees = async (): Promise<Trainee[]> => {
    const res = await fetchApi<UserResponseData[]>(
      USER_ENDPOINTS.TRAINEES,
      "GET",
    );

    if (res.isError || !res.data) {
      throw new Error(`Fetch trainees failed: ${res.error?.message}`);
    }

    return res.data.map(
      (item: any) =>
        new Trainee(item, item.trainee_id || "", item.birthday_date),
    );
  };

  const createTrainee = async (data: Partial<Trainee>): Promise<Trainee> => {
    const res = await fetchApi<UserResponseData>(
      USER_ENDPOINTS.TRAINEES,
      "POST",
      data,
    );

    if (res.isError || !res.data) {
      throw new Error(`Create trainee failed: ${res.error?.message}`);
    }

    toast.success("Trainee created successfully");
    return new Trainee(
      res.data,
      res.data.trainee_id || "",
      res.data.birthday_date,
    );
  };

  const updateTrainee = async (
    traineeId: string,
    data: Partial<Trainee>,
  ): Promise<Trainee> => {
    const res = await fetchApi<UserResponseData>(
      `${USER_ENDPOINTS.TRAINEES}/${traineeId}`,
      "PUT",
      data,
    );

    if (res.isError || !res.data) {
      throw new Error(`Update trainee failed: ${res.error?.message}`);
    }

    toast.success("Trainee updated successfully");
    return new Trainee(
      res.data,
      res.data.trainee_id || "",
      res.data.birthday_date,
    );
  };

  const deleteTrainee = async (traineeId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${USER_ENDPOINTS.TRAINEES}/${traineeId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete trainee failed: ${res.error?.message}`);
    }

    toast.success("Trainee deleted successfully");
  };

  const fetchTrainers = async (): Promise<Trainer[]> => {
    const res = await fetchApi<UserResponseData[]>(
      USER_ENDPOINTS.TRAINERS,
      "GET",
    );

    if (res.isError || !res.data) {
      throw new Error(`Fetch trainers failed: ${res.error?.message}`);
    }

    return res.data.map(
      (item: any) =>
        new Trainer(item, item.trainer_id || "", item.birthday_date),
    );
  };

  const createTrainer = async (data: Partial<Trainer>): Promise<Trainer> => {
    const res = await fetchApi<UserResponseData>(
      USER_ENDPOINTS.TRAINERS,
      "POST",
      data,
    );

    if (res.isError || !res.data) {
      throw new Error(`Create trainer failed: ${res.error?.message}`);
    }

    toast.success("Trainer created successfully");
    return new Trainer(
      res.data,
      res.data.trainer_id || "",
      res.data.birthday_date,
    );
  };

  const updateTrainer = async (
    trainerId: string,
    data: Partial<Trainer>,
  ): Promise<Trainer> => {
    const res = await fetchApi<UserResponseData>(
      `${USER_ENDPOINTS.TRAINERS}/${trainerId}`,
      "PUT",
      data,
    );

    if (res.isError || !res.data) {
      throw new Error(`Update trainer failed: ${res.error?.message}`);
    }

    toast.success("Trainer updated successfully");
    return new Trainer(
      res.data,
      res.data.trainer_id || "",
      res.data.birthday_date,
    );
  };

  const deleteTrainer = async (trainerId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${USER_ENDPOINTS.TRAINERS}/${trainerId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete trainer failed: ${res.error?.message}`);
    }

    toast.success("Trainer deleted successfully");
  };

  return {
    fetchTrainees,
    createTrainee,
    updateTrainee,
    deleteTrainee,

    fetchTrainers,
    createTrainer,
    updateTrainer,
    deleteTrainer,
  };
};
