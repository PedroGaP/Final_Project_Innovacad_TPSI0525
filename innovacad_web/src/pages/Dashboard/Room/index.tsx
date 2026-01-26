import { createResource } from "solid-js";
import type { Room } from "@/types/room";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import EntityTable from "@/components/EntityTable";

const createEmptyRoom = (): Room =>
  ({
    room_name: "",
    capacity: 0,
    has_computers: false,
    has_projector: false,
    has_whiteboard: false,
    has_smartboard: false,
  }) as unknown as Room;

const validateRoom = (room: Room): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const room_name = String(room.room_name || "").trim();
  if (!room_name) {
    errors.push("Name is required");
  }

  const capacity = String(room.capacity || "").trim();
  if (!capacity) {
    errors.push("Capacity is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldRoom: Room,
  newRoom: Room,
): {
  room_name?: string;
  capacity?: number;
  has_computers?: boolean;
  has_projector?: boolean;
  has_whiteboard?: boolean;
  has_smartboard?: boolean;
} => {
  const changes: any = {};

  if (String(oldRoom.room_name) !== String(newRoom.room_name)) {
    changes.room_name = String(newRoom.room_name);
  }

  if (String(oldRoom.capacity) !== String(newRoom.capacity)) {
    changes.capacity = Number(newRoom.capacity);
  }

  if (String(oldRoom.has_computers) !== String(newRoom.has_computers)) {
    changes.has_computers = Boolean(newRoom.has_computers);
  }

  if (String(oldRoom.has_projector) !== String(newRoom.has_projector)) {
    changes.has_projector = Boolean(newRoom.has_projector);
  }

  if (String(oldRoom.has_whiteboard) !== String(newRoom.has_whiteboard)) {
    changes.has_whiteboard = Boolean(newRoom.has_whiteboard);
  }

  if (String(oldRoom.has_smartboard) !== String(newRoom.has_smartboard)) {
    changes.has_smartboard = Boolean(newRoom.has_smartboard);
  }

  return changes;
};

const RoomsPage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Room[]>(api.fetchRooms);

  const handleSaveRoom = async (room: Room, original: Room | null) => {
    try {
      const validation = validateRoom(room);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, room);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateRoom(String(room.room_id), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) => (u.room_id === room.room_id ? room : u)) || [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Room updated successfully (${changedFieldNames})`);
      } else {
        const roomObj = {
          room_name: String(room.room_name),
          capacity: Number(room.capacity),
          has_computers: Boolean(room.has_computers),
          has_projector: Boolean(room.has_projector),
          has_whiteboard: Boolean(room.has_whiteboard),
          has_smartboard: Boolean(room.has_smartboard),
        };

        const newRoom = await api.createRoom(roomObj);

        mutate((prev) => [...(prev || []), newRoom]);
        toast.success("Room created successfully.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save room");
      }
      throw error;
    }
  };

  const confirmDelete = async (userToDelete: Room) => {
    await api.deleteRoom(String(userToDelete.room_id));
    mutate(
      (prev) => prev?.filter((u) => u.room_id !== userToDelete.room_id) || [],
    );
  };

  return (
    <EntityTable<Room>
      title="Manage Rooms"
      data={usersData}
      handleEditClick={(room) => ({
        ...room,
      })}
      handleAddClick={() => createEmptyRoom()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveRoom}
      filter={(e: Room, search: string) => {
        const s = search.toLowerCase();
        return e.room_name?.toLowerCase().includes(s) ?? false;
      }}
      fields={[
        {
          formattedName: "ID",
          fieldName: "room_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Name",
          fieldName: "room_name",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Capacity",
          fieldName: "capacity",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Has Computers ?",
          fieldName: "has_computers",
          smaller: true,
        },
        {
          formattedName: "Has Projector ?",
          fieldName: "has_projector",
          smaller: true,
        },
        {
          formattedName: "Has Whiteboard ?",
          fieldName: "has_whiteboard",
          smaller: true,
        },
        {
          formattedName: "Has Smartboard ?",
          fieldName: "has_smartboard",
          smaller: true,
        },
      ]}
    />
  );
};

export default RoomsPage;
