import { Show, createResource, For, createMemo } from "solid-js";
import { X, GraduationCap, Award } from "lucide-solid";
import { useApi } from "@/hooks/useApi";
import { Grade, GradeStatusEnum, GradeTypeEnum } from "@/types/grade";

interface Props {
  isOpen: boolean;
  onClose: () => void;
  enrollment: {
    class_id: string;
    trainee_id: string;
    courseName: string;
    classIdentifier: string;
    finalGrade: string;
  };
}

const EnrollmentDetailsModal = (props: Props) => {
  const api = useApi();

  const [allGrades] = createResource(
    () => (props.isOpen ? props.enrollment.trainee_id : null),
    api.fetchGradesByTrainee,
  );

  const [modulesResource] = createResource(
    () => (props.isOpen ? props.enrollment.class_id : null),
    api.fetchModulesByClass,
  );

  const moduleGradesList = createMemo(() => {
    const modules = modulesResource();
    const grades = allGrades();

    if (!modules || !grades) return [];

    return modules.map((mod: any) => {
      const modId = mod.module_id;

      const findGrade = (type: GradeTypeEnum) =>
        grades.find(
          (g: Grade) =>
            g.module_id === modId &&
            g.grade_type === type &&
            g.status === GradeStatusEnum.FINALIZED,
        )?.grade || 0;

      return {
        name: mod.module_name || mod.name,
        attendance: findGrade(GradeTypeEnum.ATTENDANCE),
        behavior: findGrade(GradeTypeEnum.BEHAVIOR),
        work: findGrade(GradeTypeEnum.WORK),
        test: findGrade(GradeTypeEnum.TEST),
        final: findGrade(GradeTypeEnum.FINAL),
      };
    });
  });

  console.log(`ENROLLMENT::: ${JSON.stringify(props.enrollment)}`);
  console.log(`ENROLLMENT FINAL GRADE::: ${props.enrollment.finalGrade}`);

  return (
    <Show when={props.isOpen}>
      <div class="modal modal-open">
        <div class="modal-box w-11/12 max-w-5xl border border-base-300 shadow-2xl p-0 overflow-hidden">
          <div class="bg-primary p-6 text-primary-content flex justify-between items-center">
            <div class="flex items-center gap-4">
              <div class="p-3 bg-white/20 rounded-lg">
                <GraduationCap size={32} />
              </div>
              <div>
                <h3 class="font-bold text-2xl">Academic Record</h3>
                <p class="text-sm opacity-80 font-mono">
                  {props.enrollment.courseName} |{" "}
                  {props.enrollment.classIdentifier}
                </p>
              </div>
            </div>
            <button
              class="btn btn-sm btn-circle btn-ghost"
              onClick={props.onClose}
            >
              <X size={20} />
            </button>
          </div>

          <div class="p-6">
            <div class="stats shadow border border-base-200 w-full mb-6">
              <div class="stat">
                <div class="stat-figure text-primary">
                  <Award size={32} />
                </div>
                <div class="stat-title">Overall Course Grade</div>
                <div
                  class={`stat-value ${Number(props.enrollment.finalGrade) >= 9.5 ? "text-success" : "text-error"}`}
                >
                  {props.enrollment.finalGrade}
                </div>
                <div class="stat-desc text-xs uppercase opacity-50 font-bold">
                  Updated in real-time
                </div>
              </div>
            </div>

            <div class="overflow-x-auto rounded-xl border border-base-200">
              <table class="table table-zebra table-sm">
                <thead class="bg-base-200">
                  <tr>
                    <th class="py-4">Module Name</th>
                    <th class="text-center">Atten. (5%)</th>
                    <th class="text-center">Behav. (5%)</th>
                    <th class="text-center">Work (30%)</th>
                    <th class="text-center">Test (60%)</th>
                    <th class="text-center font-bold text-primary">Final</th>
                  </tr>
                </thead>
                <tbody>
                  <Show
                    when={!modulesResource.loading && !allGrades.loading}
                    fallback={
                      <tr>
                        <td colspan="6" class="text-center p-10">
                          <span class="loading loading-spinner loading-lg text-primary"></span>
                        </td>
                      </tr>
                    }
                  >
                    <For
                      each={moduleGradesList()}
                      fallback={
                        <tr>
                          <td colspan="6" class="text-center py-4">
                            No modules found.
                          </td>
                        </tr>
                      }
                    >
                      {(mod) => (
                        <tr class="hover">
                          <td class="font-medium max-w-xs truncate">
                            {mod.name}
                          </td>
                          <td class="text-center opacity-70">
                            {Number(mod.attendance).toFixed(1)}
                          </td>
                          <td class="text-center opacity-70">
                            {Number(mod.behavior).toFixed(1)}
                          </td>
                          <td class="text-center opacity-70">
                            {Number(mod.work).toFixed(1)}
                          </td>
                          <td class="text-center opacity-70">
                            {Number(mod.test).toFixed(1)}
                          </td>
                          <td class="text-center">
                            <div
                              class={`badge badge-md font-bold ${mod.final >= 9.5 ? "badge-success" : "badge-error"} badge-outline`}
                            >
                              {Number(mod.final).toFixed(2)}
                            </div>
                          </td>
                        </tr>
                      )}
                    </For>
                  </Show>
                </tbody>
              </table>
            </div>
          </div>

          <div class="p-6 pt-0">
            <button class="btn btn-block" onClick={props.onClose}>
              Close View
            </button>
          </div>
        </div>
      </div>
    </Show>
  );
};

export default EnrollmentDetailsModal;
