defmodule Wttj.JobsTest do
  use Wttj.DataCase

  alias Wttj.Jobs

  describe "jobs" do
    alias Wttj.Jobs.Job

    @valid_attrs %{
      contract_type: "some contract_type",
      name: "some name",
      office_location: "some office_location"
    }
    @update_attrs %{
      contract_type: "some updated contract_type",
      name: "some updated name",
      office_location: "some updated office_location"
    }
    @invalid_attrs %{contract_type: nil, name: nil, office_location: nil}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Jobs.create_job(@valid_attrs)
      assert job.contract_type == "some contract_type"
      assert job.name == "some name"
      assert job.office_location == "some office_location"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, %Job{} = job} = Jobs.update_job(job, @update_attrs)
      assert job.contract_type == "some updated contract_type"
      assert job.name == "some updated name"
      assert job.office_location == "some updated office_location"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end
end
