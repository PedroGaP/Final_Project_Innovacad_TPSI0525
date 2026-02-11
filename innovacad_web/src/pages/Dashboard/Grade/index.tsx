import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import type { Class } from "@/types/class";
import { GradeStatusEnum, GradeTypeEnum } from "@/types/grade";
import {
  createEffect,
  createMemo,
  createResource,
  createSignal,
  For,
  Show,
} from "solid-js";
import toast from "solid-toast";
import { BookOpen, Crown, Lock, Save, X } from "lucide-solid";

interface ModuleRow {
  unique_id: string;
  class_id: string;
  class_identifier: string;
  class_location: string;
  module_id: string;
  module_name: string;
  trainer_id: string;
}

interface StudentGradeRow {
  trainee_id: string;
  trainee_name: string;
  attendance: number;
  behavior: number;
  work: number;
  test: number;
  final: number;
  status: GradeStatusEnum;
}

const normalizeId = (id: any) =>
  String(id || "")
    .trim()
    .toLowerCase();

const calculateFinal = (r: StudentGradeRow) => {
  return r.attendance * 0.05 + r.behavior * 0.05 + r.work * 0.3 + r.test * 0.6;
};

const GradeSheetModal = (props: {
  isOpen: boolean;
  onClose: () => void;
  classModuleId: string;
  className: string;
  moduleName: string;
  canFinalize: boolean;
  classId: string;
}) => {
  const api = useApi();
  const [loading, setLoading] = createSignal(false);
  const [rows, setRows] = createSignal<StudentGradeRow[]>([]);

  const [isFinalized, setIsFinalized] = createSignal(false);

  const loadData = async () => {
    if (!props.classModuleId || !props.classId) return;

    setLoading(true);
    try {
      const [existingGradesRes, allEnrollmentsRes, allTraineesRes] =
        await Promise.all([
          api.fetchGradesByModule(props.classModuleId).catch(() => []),
          api.fetchEnrollments().catch(() => []),
          api.fetchTrainees().catch(() => []),
        ]);

      const classEnrollments = allEnrollmentsRes.filter(
        (e) => normalizeId(e.class_id) === normalizeId(props.classId),
      );

      const traineeMap = new Map<string, StudentGradeRow>();

      classEnrollments.forEach((e) => {
        const trainee = allTraineesRes.find(
          (t) => normalizeId(t.traineeId) === normalizeId(e.trainee_id),
        );
        const name = trainee ? trainee.name : "Unknown Trainee";

        traineeMap.set(normalizeId(e.trainee_id), {
          trainee_id: String(e.trainee_id),
          trainee_name: name!,
          attendance: 0,
          behavior: 0,
          work: 0,
          test: 0,
          final: 0,
          status: GradeStatusEnum.DRAFT,
        });
      });

      let foundFinalized = false;

      existingGradesRes.forEach((g) => {
        const tId = normalizeId(g.trainee_id);
        if (traineeMap.has(tId)) {
          const row = traineeMap.get(tId)!;
          if (g.grade_type === GradeTypeEnum.ATTENDANCE)
            row.attendance = Number(g.grade);
          if (g.grade_type === GradeTypeEnum.BEHAVIOR)
            row.behavior = Number(g.grade);
          if (g.grade_type === GradeTypeEnum.WORK) row.work = Number(g.grade);
          if (g.grade_type === GradeTypeEnum.TEST) row.test = Number(g.grade);

          if (g.status === GradeStatusEnum.FINALIZED) {
            row.status = GradeStatusEnum.FINALIZED;
            foundFinalized = true;
          }

          row.final = calculateFinal(row);
        }
      });

      setIsFinalized(foundFinalized); // Atualiza o estado
      setRows(Array.from(traineeMap.values()));
    } catch (e: any) {
      toast.error("Failed to load data: " + e.message);
    } finally {
      setLoading(false);
    }
  };

  createEffect(() => {
    if (props.isOpen && props.classModuleId && props.classId) {
      loadData();
    }
  });

  const handleInputChange = (
    traineeId: string,
    field: keyof StudentGradeRow,
    value: string,
  ) => {
    const numValue = Math.min(20, Math.max(0, Number(value)));
    setRows((prev) =>
      prev.map((row) => {
        if (row.trainee_id === traineeId) {
          const updated = { ...row, [field]: numValue };
          updated.final = calculateFinal(updated);
          return updated;
        }
        return row;
      }),
    );
  };

  const handleSave = async () => {
    const gradesToSave: any[] = [];
    rows().forEach((row) => {
      const types = [
        { type: GradeTypeEnum.ATTENDANCE, val: row.attendance },
        { type: GradeTypeEnum.BEHAVIOR, val: row.behavior },
        { type: GradeTypeEnum.WORK, val: row.work },
        { type: GradeTypeEnum.TEST, val: row.test },
        { type: GradeTypeEnum.FINAL, val: row.final },
      ];

      types.forEach((t) => {
        gradesToSave.push({
          trainee_id: row.trainee_id,
          grade: t.val,
          grade_type: t.type,
        });
      });
    });

    try {
      await api.batchUpsertGrades({
        class_module_id: props.classModuleId,
        grades: gradesToSave,
      });
      toast.success("Grades saved successfully!");
      props.onClose();
    } catch (e: any) {
      toast.error(e.message);
    }
  };

  const handleFinalize = async () => {
    if (!confirm("Are you sure? This will LOCK the grades definitively."))
      return;
    try {
      await handleSave();
      await api.finalizeGrades(props.classModuleId);
      toast.success("Module grades finalized.");
      setIsFinalized(true); // Bloqueia a UI imediatamente
      props.onClose();
    } catch (e: any) {
      toast.error(e.message);
    }
  };

  return (
    <Show when={props.isOpen}>
      <div class="modal modal-open">
        <div class="modal-box w-11/12 max-w-6xl">
          <div class="flex justify-between items-center mb-4">
            <h3 class="font-bold text-lg">
              Grade Sheet: <span class="text-primary">{props.className}</span> -{" "}
              {props.moduleName}
            </h3>
            <button
              class="btn btn-sm btn-circle btn-ghost"
              onClick={props.onClose}
            >
              <X size={20} />
            </button>
          </div>

          <div class="overflow-x-auto min-h-75">
            <Show
              when={!loading()}
              fallback={
                <div class="flex justify-center p-10">
                  <span class="loading loading-spinner loading-lg"></span>
                </div>
              }
            >
              <table class="table table-xs md:table-sm">
                <thead>
                  <tr>
                    <th class="w-48">Trainee</th>
                    <th class="w-24 text-center">Assiduity (5%)</th>
                    <th class="w-24 text-center">Behavior (5%)</th>
                    <th class="w-24 text-center">Work (30%)</th>
                    <th class="w-24 text-center">Test (60%)</th>
                    <th class="w-24 text-center font-bold">Final</th>
                  </tr>
                </thead>
                <tbody>
                  <For each={rows()}>
                    {(row) => (
                      <tr class="hover">
                        <td class="font-medium">{row.trainee_name}</td>
                        <td>
                          <input
                            type="number"
                            min="0"
                            max="20"
                            class="input input-bordered input-xs w-full text-center"
                            value={row.attendance}
                            onInput={(e) =>
                              handleInputChange(
                                row.trainee_id,
                                "attendance",
                                e.currentTarget.value,
                              )
                            }
                            disabled={isFinalized()}
                          />
                        </td>
                        <td>
                          <input
                            type="number"
                            min="0"
                            max="20"
                            class="input input-bordered input-xs w-full text-center"
                            value={row.behavior}
                            onInput={(e) =>
                              handleInputChange(
                                row.trainee_id,
                                "behavior",
                                e.currentTarget.value,
                              )
                            }
                            disabled={isFinalized()}
                          />
                        </td>
                        <td>
                          <input
                            type="number"
                            min="0"
                            max="20"
                            class="input input-bordered input-xs w-full text-center"
                            value={row.work}
                            onInput={(e) =>
                              handleInputChange(
                                row.trainee_id,
                                "work",
                                e.currentTarget.value,
                              )
                            }
                            disabled={isFinalized()}
                          />
                        </td>
                        <td>
                          <input
                            type="number"
                            min="0"
                            max="20"
                            class="input input-bordered input-xs w-full text-center"
                            value={row.test}
                            onInput={(e) =>
                              handleInputChange(
                                row.trainee_id,
                                "test",
                                e.currentTarget.value,
                              )
                            }
                            disabled={isFinalized()}
                          />
                        </td>
                        <td class="text-center font-bold">
                          <div
                            class={`badge ${row.final >= 9.5 ? "badge-success" : "badge-error"} badge-sm`}
                          >
                            {row.final.toFixed(2)}
                          </div>
                        </td>
                      </tr>
                    )}
                  </For>
                </tbody>
              </table>
            </Show>
          </div>

          <div class="modal-action flex justify-between items-center">
            <div class="text-xs opacity-50">
              {isFinalized()
                ? "Grade sheet LOCKED."
                : "Remember to save changes."}
            </div>
            <div class="flex gap-2">
              <Show when={props.canFinalize && !isFinalized()}>
                <button
                  class="btn btn-error btn-sm text-white"
                  onClick={handleFinalize}
                >
                  <Lock size={16} /> Finalize Grades
                </button>
              </Show>
              <Show when={!isFinalized()}>
                <button class="btn btn-primary btn-sm" onClick={handleSave}>
                  <Save size={16} /> Save
                </button>
              </Show>
            </div>
          </div>
        </div>
      </div>
    </Show>
  );
};

const GradesPage = () => {
  const api = useApi();
  const { user } = useUserDetails();

  const [classes] = createResource<Class[]>(api.fetchClasses);
  const [isModalOpen, setIsModalOpen] = createSignal(false);
  const [selectedModule, setSelectedModule] = createSignal<ModuleRow | null>(
    null,
  );

  const modulesList = createMemo(() => {
    const list: ModuleRow[] = [];
    const allClasses = classes();
    if (!allClasses) return [];

    const u = user();
    if (!u) return [];

    let myId = normalizeId(u.id);
    if ("trainer_id" in u) {
      myId = normalizeId((u as any).trainer_id);
    }

    const role = u.role;
    const coordinatedClassIds = ((u as any).coordinated_class_ids || []).map(
      (id: any) => normalizeId(id),
    );

    allClasses.forEach((cls) => {
      const classId = normalizeId(cls.class_id);
      const isCoordOfThisClass =
        role === "coordinator" && coordinatedClassIds.includes(classId);

      cls.modules?.forEach((mod: any) => {
        const modTrainerId = normalizeId(mod.trainer_id || mod.trainerId);
        const amITheTrainer = modTrainerId === myId;

        let canView = false;
        if (role === "admin") {
          canView = true;
        } else if (role === "coordinator") {
          if (isCoordOfThisClass || amITheTrainer) canView = true;
        } else {
          if (amITheTrainer) canView = true;
        }

        if (canView) {
          list.push({
            unique_id: `${cls.class_id}_${mod.classes_modules_id || mod.courses_modules_id}`,
            class_id: String(cls.class_id),
            class_identifier: cls.identifier || "N/A",
            class_location: cls.location || "N/A",
            module_id: String(mod.classes_modules_id || mod.courses_modules_id),
            module_name: mod.module_name,
            trainer_id: modTrainerId,
          });
        }
      });
    });

    return list;
  });

  const handleOpenPauta = (row: ModuleRow) => {
    setSelectedModule(row);
    setIsModalOpen(true);
  };

  const isCoordinatorOf = (classId: string) => {
    const u = user();
    if (u?.role === "admin") return true;
    if (u?.role === "coordinator") {
      const coordinatedIds = ((u as any).coordinated_class_ids || []).map(
        (id: any) => normalizeId(id),
      );
      return coordinatedIds.includes(normalizeId(classId));
    }
    return false;
  };

  return (
    <>
      <EntityTable<ModuleRow>
        title="Grade Sheets"
        data={modulesList}
        handleAddClick={undefined}
        confirmDelete={undefined}
        handleSave={async () => {}}
        handleEditClick={(row) => {
          handleOpenPauta(row);
          return undefined;
        }}
        formFields={[]}
        filter={(row, search) => {
          const s = search.toLowerCase();
          return (
            row.module_name.toLowerCase().includes(s) ||
            row.class_identifier.toLowerCase().includes(s)
          );
        }}
        fields={[
          {
            formattedName: "Role",
            fieldName: "class_id",
            smaller: true,
            customGeneration: (r) => {
              const isCoord = isCoordinatorOf(r.class_id);
              return (
                <div
                  class={`badge gap-1 ${isCoord ? "badge-primary" : "badge-ghost"}`}
                >
                  {isCoord ? <Crown size={12} /> : <BookOpen size={12} />}
                  {isCoord ? "Coordinator" : "Trainer"}
                </div>
              );
            },
          },
          {
            formattedName: "Class",
            fieldName: "class_identifier",
            customGeneration: (r) => (
              <div class="flex flex-col">
                <span class="font-bold">{r.class_identifier}</span>
                <span class="text-xs opacity-60">({r.class_location})</span>
              </div>
            ),
          },
          { formattedName: "Module", fieldName: "module_name" },
          {
            formattedName: "Action",
            fieldName: "module_id",
            customGeneration: (r) => {
              const isCoord = isCoordinatorOf(r.class_id);
              return (
                <button
                  class={`btn btn-sm btn-outline ${isCoord ? "btn-primary" : "btn-ghost"}`}
                  onClick={() => handleOpenPauta(r)}
                >
                  {isCoord ? "Manage Grades" : "Enter Grades"}
                </button>
              );
            },
          },
        ]}
      />

      <Show when={selectedModule() && isModalOpen()}>
        <GradeSheetModal
          isOpen={isModalOpen()}
          onClose={() => {
            setIsModalOpen(false);
          }}
          classModuleId={selectedModule()?.module_id!}
          className={selectedModule()?.class_identifier!}
          moduleName={selectedModule()?.module_name!}
          classId={selectedModule()?.class_id!}
          canFinalize={isCoordinatorOf(selectedModule()?.class_id!)}
        />
      </Show>
    </>
  );
};

export default GradesPage;
