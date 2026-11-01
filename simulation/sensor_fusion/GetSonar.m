function [h, att] = GetSonar()
    persistent sonarAlt attitudeData
    persistent k firstRun

    if isempty(firstRun)
        load('imu_flight_path.mat', 'flight_data');
        k = 1;
        firstRun = 1;
    end

    load('imu_flight_path.mat', 'flight_data');
    h = flight_data.position(k, 3);
    att = flight_data.attitude(k, :);
    k = k + 1;
end